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

    # performed here to avoid slow transactions as requires API call to the OS API
    cached_autograntable = autograntable(submission:)

    PriorAuthorityApplication.transaction do
      update_submission(submission, json_data)

      autogrant(submission) if cached_autograntable
    end
  end

  def autograntable(submission:)
    # performed here to avoid slow transactions as requires API call to the OS API
    Autograntable.new(submission:).grantable?
  rescue LocationService::LocationError
    false
  end

  def update_submission(submission, json_data)
    submission.save!

    json_data['events']&.each do |event|
      submission.events.rehydrate!(event)
    end
    Event::NewVersion.build(submission:)
  end

  def autogrant(submission)
    previous_state = submission.state
    submission.update!(state: PriorAuthorityApplication::AUTO_GRANT)

    Event::AutoDecision.build(submission:, previous_state:)
    NotifyAppStore.process(submission:)
  end
end
