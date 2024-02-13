class MakeDecisionService < ApplicationJob
  queue_as :default

  def self.process(submission:, comment:, user_id:, application_state:)
    if ENV.key?('REDIS_HOST')
      set(wait: Rails.application.config.x.application.app_store_wait.seconds)
        .perform_later(submission, comment, user_id, application_state)
    else
      begin
        AppStoreService.change_state(submission, comment:, user_id:, application_state:)
        SubmissionFeedbackMailer.notify(submission.id, application_state).deliver_later!
      rescue StandardError => e
        # we only get errors here when processing inline, which we don't want
        # to be visible to the end user, so swallow errors
        Sentry.capture_exception(e)
      end
    end
  end

  def perform(submission, comment, user_id, application_state)
    AppStoreService.change_state(submission, comment:, user_id:, application_state:)
    SubmissionFeedbackMailer.notify(submission.id, application_state).deliver_later!
  end
end
