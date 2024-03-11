class NotifyAppStore < ApplicationJob
  queue_as :default

  def self.process(submission:)
    if ENV.key?('REDIS_HOST')
      set(wait: Rails.application.config.x.application.app_store_wait.seconds)
        .perform_later(submission)
    else
      begin
        new.notify(MessageBuilder.new(submission:))
        new.send_email(submission)
      rescue StandardError => e
        # we only get errors here when processing inline, which we don't want
        # to be visible to the end user, so swallow errors
        Sentry.capture_exception(e)
      end
    end
  end

  def perform(submission)
    notify(MessageBuilder.new(submission:))
    send_email(submission)
  end

  def notify(message_builder)
    raise 'SNS notification is not yet enabled' if ENV.key?('SNS_URL')

    # implement and call SNS notification

    # TODO: we only do post requests here as the system is not currently
    # able to support re-sending/submitting an appplication so we can ignore
    # put requests
    post_manager = HttpNotifier.new
    post_manager.put(message_builder.message)
  end

  def send_email(submission)
    if submission.application_type == 'crm7'
      Nsm::SubmissionFeedbackMailer.notify(submission).deliver_later!
    elsif submission.application_type == 'crm4'
      # TODO: add email code for CRM4
    end
  end
end
