class PullLatestVersionData < ApplicationJob
  # queue :default

  def perform(submission)
    # data for required version is already here
    return if submission.data.present?

    json_data = HttpPuller.new.get(submission)

    if json_data['version'] == submission.current_version
      save(submission, json_data)
    elsif json_data['version'] > submission.current_version
      # ignore this data as we will see a new metadata update for this
      # we could handle it here but that complicates the flow
      # NOTE: this should never happen
    else
      raise "Correct version not found on AppStore: #{submission.id} - " \
            "#{submission.current_version} only found #{json_data['version']}"
    end

    # reset any data confirmations where data has changed
  end

  private

  def save(submission, json_data)
    submission.assign_attributes(
      json_schema_version: json_data['json_schema_version'],
      data: json_data['application']
    )
    check_data_format(submission)
    submission.save!
    json_data['events']&.each do |event|
      submission.events.rehydrate!(event)
    end
    Event::NewVersion.build(submission:)
  end

  def check_data_format(submission)
    # In the absence of a formal schema for JSON blobs, this will serve as a temporary measure
    # to flag up mismatches between what the provider app submits to the ap store and the
    # structure that the current codebase expects
    return unless submission.namespace == PriorAuthority

    checker = PriorAuthority::ApplicationAssumptionChecker.new(submission.data)
    return if checker.valid?

    raise "Received submission data that does not adhere to our assumptions: \n" \
          "#{checker.errors.full_messages.join("\n")}"
  end
end
