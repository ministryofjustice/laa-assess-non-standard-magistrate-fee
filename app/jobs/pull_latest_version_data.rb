class PullLatestVersionData < ApplicationJob
  # queue :default

  def perform(claim)
    # data for required version is already here
    return if claim.versions.find_by(version: claim.current_version)

    json_data = HttpPuller.new.get(claim)

    if json_data['version'] == claim.current_version
      create_version(claim, json_data)
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

  def create_version(claim, json_data)
    claim.versions.create!(
      version: json_data['version'],
      json_schema_version: json_data['json_schema_version'],
      state: json_data['application_state'],
      data: json_data['application']
    )
    Event::NewVersion.build(claim:)
  end
end
