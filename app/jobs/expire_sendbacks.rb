class ExpireSendbacks < ApplicationJob
  def perform
    [PriorAuthorityApplication, Claim].each do |klass|
      klass.sent_back
           .where("(data->>'resubmission_deadline')::timestamp < NOW()")
           .find_each { expire(_1) }
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
