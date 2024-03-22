class ExpireSendbacks < ApplicationJob
  def perform
    PriorAuthorityApplication.where(state: PriorAuthorityApplication::SENT_BACK)
                             .where('updated_at < ?', Rails.application.config.x.rfi.resubmission_window.ago)
                             .find_each do |expirable|
                               expire(expirable)
                             end
  end

  private

  def expire(submission)
    submission.update!(state: PriorAuthorityApplication::EXPIRED)
    Event::Expiry.build(submission:)
    NotifyAppStore.process(submission: submission, trigger_email: false)
  end
end
