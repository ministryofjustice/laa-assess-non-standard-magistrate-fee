class MakeDecisionService < ApplicationJob
  queue_as :default

  def self.process(submission:)
    if ENV.key?('REDIS_HOST')
      set(wait: Rails.application.config.x.application.app_store_wait.seconds)
        .perform_later(submission)
    else
      begin
        AppStoreService.update(submission)
        SubmissionFeedbackMailer.notify(submission).deliver_later!
      rescue StandardError => e
        # we only get errors here when processing inline, which we don't want
        # to be visible to the end user, so swallow errors
        Sentry.capture_exception(e)
      end
    end
  end

  def perform(submission)
    AppStoreService.update(submission)
    SubmissionFeedbackMailer.notify(submission).deliver_later!
  end
end
