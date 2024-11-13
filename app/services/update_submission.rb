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
      # ensure new_version happens before the Autogrant
      Event::NewVersion.build(submission:) if new_version_appropriate? && version_changed
      autogrant if cached_autograntable
    end

    NotifyAppStore.perform_now(submission:) if cached_autograntable

    submission
  end

  def new_version_appropriate?
    # If this is a prior authority submission, only add a new version event on the first new version
    @record['version'] == 1 ||
      (@record['application_type'] == Submission::APPLICATION_TYPES[:nsm] && @record['application_state'] == 'provider_updated')
  end

  def assign_attributes
    submission.assign_attributes(Submission.attributes_from_app_store_data(@record))
    submission.received_on ||= Time.zone.today
  end

  private

  def autograntable?
    # performed here to avoid slow transactions as requires API call to the OS API
    Autograntable.new(submission:).grantable?
  rescue LocationService::NotFoundError, LocationService::UnknowablePartialPostcode
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
    submission.data.merge!('updated_at' => Time.current, 'status' => PriorAuthorityApplication::AUTO_GRANT)
    submission.update!(state: PriorAuthorityApplication::AUTO_GRANT)

    Event::AutoDecision.build(submission:, previous_state:)
  end
end
