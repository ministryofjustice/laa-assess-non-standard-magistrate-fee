class NotifyAppStore < ApplicationJob
  queue_as :default

  def self.perform_later(submission:, trigger_email: true)
    submission.update!(notify_app_store_completed: false)
    super
  end

  def perform(submission:, trigger_email: true)
    # This lock is important because it forces the job to wait until
    # the locked transaction that enqueued this job is released,
    # ensuring that when this job runs it is working with fresh
    # data
    submission.with_lock do
      notify(MessageBuilder.new(submission:))

      send_email(submission:, trigger_email:)
      submission.update!(notify_app_store_completed: true)
    end
  end

  def notify(message_builder)
    client = AppStoreClient.new
    client.update_submission(message_builder.message)
  end

  def send_email(submission:, trigger_email:)
    return unless trigger_email && ENV.fetch('SEND_EMAILS', 'false') == 'true'

    klass = "#{submission.namespace}::SubmissionFeedbackMailer".constantize
    klass.notify(submission).deliver_later!
  end
end
