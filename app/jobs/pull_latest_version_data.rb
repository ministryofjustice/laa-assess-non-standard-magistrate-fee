class PullLatestVersionData < ApplicationJob
  # queue :default

  def perform(claim)
    # data for required version is already here
    return if claim.data.present?

    json_data = HttpPuller.new.get(claim)

    if json_data['version'] == claim.current_version
      save(claim, json_data)
    elsif json_data['version'] > claim.current_version
      # ignore this data as we will see a new metadata update for this
      # we could handle it here but that complicates the flow
      # NOTE: this should never happen
    else
      raise "Correct version not found on AppStore: #{claim.id} - " \
            "#{claim.current_version} only found #{json_data['version']}"
    end

    # reset any data confirmations where data has changed
  end

  private

  def save(claim, json_data)
    claim.update!(
      json_schema_version: json_data['json_schema_version'],
      data: json_data['application']
    )
    json_data['events']&.each do |event|
      claim.events.rehydrate!(event)
    end
    Event::NewVersion.build(crime_application: claim)
  end
end
