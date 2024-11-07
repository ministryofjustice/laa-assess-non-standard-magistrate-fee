class SendEmailToProvider < ApplicationJob
  def self.perform_later(submission)
    submission.update!(send_email_to_provider_completed: false)
    super(submission.id)
  end

  def perform(submission_id)
    submission = Submission.find(submission_id)
    # This lock is important as it forces the job to wait until the locking
    # transaction in which the job was enqueued to be released, which will
    # happen when the transaction is committed. If we were to run this job
    # any earlier we might here be dealing with out of date data
    submission.with_lock do
      klass = "#{submission.namespace}::EmailToProviderMailer".constantize
      klass.notify(submission).deliver_now!
      submission.update!(send_email_to_provider_completed: true)
    end
  end
end
