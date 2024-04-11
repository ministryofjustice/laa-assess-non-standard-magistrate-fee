class ReceiveApplicationMetadata
  attr_reader :submission

  delegate :errors, to: :submission

  def initialize(record, is_full: false)
    @submission = Submission.find_or_initialize_by(id: record['application_id'])
    @record = record
    @is_full = is_full
  end

  def attributes
    {
      state: @record['application_state'],
      risk: @record['application_risk'],
      current_version: @record['version'],
      app_store_updated_at: @record['updated_at'],
      application_type: @record['application_type'],
    }
  end

  def save
    @submission.assign_attributes(attributes)
    # set default if this is a new record
    @submission.received_on ||= Time.zone.today

    return unless @submission.save

    if @is_full
      PopulateSubmissionDetails.call(@submission, @record)
    else
      PullLatestVersionData.perform_later(@submission)
    end
  end
end
