class ExpireSendbacks < ApplicationJob
  def perform
    PriorAuthorityApplication.sent_back
                             .where(updated_at: ...Rails.application.config.x.rfi.resubmission_window.ago)
                             .find_each do |expirable|
                               expire(expirable)
                             end
  end

  private

  def expire(submission)
    submission.data.merge!('updated_at' => Time.current, 'status' => PriorAuthorityApplication::EXPIRED)
    submission.expired!
    Event::Expiry.build(submission:)
    NotifyAppStore.perform_later(submission: submission, trigger_email: false)
  end
end
