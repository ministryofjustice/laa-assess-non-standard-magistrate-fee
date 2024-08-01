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
      Event::NewVersion.build(submission:) if new_version_appropriate? && version_changed
    end

    submission
  end

  def new_version_appropriate?
    # If this is a prior authority submission, only add a new version event on the first new version
    @record['version'] == 1 || @record['application_type'] != Submission::APPLICATION_TYPES[:prior_authority]
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
    last_updated_at = submission.created_at
    # Events may not exist or dirty data means some may not have certain expected fields
    if @record['events']
      usable_events = @record['events'].select {|ev| ev['created_at'].present? }

      if usable_events.any?
        latest_event = usable_events.max_by { |ev| ev["created_at"].to_time }
        last_updated_at = latest_event['created_at'].to_time
      end
    end
    submission.update_columns(last_updated_at:)

    @record['events']&.each do |event|
      submission.events.rehydrate!(event, submission.application_type)
    end
  end

  def autogrant
    previous_state = submission.state
    submission.update!(state: PriorAuthorityApplication::AUTO_GRANT)

    Event::AutoDecision.build(submission:, previous_state:)
    NotifyAppStore.perform_later(submission:)
  end
end
