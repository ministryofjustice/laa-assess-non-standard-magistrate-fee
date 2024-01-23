class ReceiveApplicationMetadata
  attr_reader :submission

  delegate :errors, to: :submission

  def initialize(submission_id)
    @submission = Submission.find_or_initialize_by(id: submission_id)
  end

  def save(params)
    submission.assign_attributes(params)
    # set default if this is a new record
    submission.received_on ||= Time.zone.today

    return unless submission.save

    PullLatestVersionData.perform_later(submission)
  end
end
