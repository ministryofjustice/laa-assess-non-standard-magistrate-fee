class NotifyAppStore < ApplicationJob
  queue_as :default

  def perform(submission:, trigger_email: true)
    notify(MessageBuilder.new(submission:))

    return unless trigger_email

    klass = "#{submission.namespace}::SubmissionFeedbackMailer".constantize
    klass.notify(submission).deliver_later!
  end

  def notify(message_builder)
    client = AppStoreClient.new
    client.update_submission(message_builder.message)
  end
end
