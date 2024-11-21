class SendEmailToProvider < ApplicationJob
  def self.perform_later(submission)
    super(submission.id)
  end

  def perform(submission_id)
    submission = Submission.load_from_app_store(submission_id)
    klass = "#{submission.namespace}::EmailToProviderMailer".constantize
    klass.notify(submission).deliver_now!
  end
end
