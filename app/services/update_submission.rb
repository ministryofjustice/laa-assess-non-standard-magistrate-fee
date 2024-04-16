class UpdateSubmission
  attr_reader :submission

  delegate :errors, to: :submission

  def self.call(record)
    new(record).save
  end

  def initialize(record)
    @submission = Submission.find_or_initialize_by(id: record['application_id'])
    @record = record
  end

  def save
    version_changed = @record['version'] > (submission.current_version || 0)

    assign_attributes

    # performed here to avoid slow transactions as requires API call to the OS API
    cached_autograntable = autograntable?

    PriorAuthorityApplication.transaction do
      update_submission
      autogrant if cached_autograntable
      Event::NewVersion.build(submission:) if version_changed
    end
  end

  def assign_attributes
    submission.assign_attributes(attributes)
    submission.received_on ||= Time.zone.today
  end

  def attributes
    {
      state: @record['application_state'],
      risk: @record['application_risk'],
      current_version: @record['version'],
      app_store_updated_at: @record['updated_at'],
      application_type: @record['application_type'],
      json_schema_version: @record['json_schema_version'],
      data: @record['application']
    }
  end

  private

  def autograntable?
    # performed here to avoid slow transactions as requires API call to the OS API
    Autograntable.new(submission:).grantable?
  rescue LocationService::NotFoundError
    false
  rescue LocationService::LocationError => e
    Sentry.capture_exception(e)
    false
  end

  def update_submission
    submission.save!

    @record['events']&.each do |event|
      submission.events.rehydrate!(event, submission.application_type)
    end
  end

  def autogrant
    previous_state = submission.state
    submission.update!(state: PriorAuthorityApplication::AUTO_GRANT)

    Event::AutoDecision.build(submission:, previous_state:)
    NotifyAppStore.process(submission:)
  end
end
