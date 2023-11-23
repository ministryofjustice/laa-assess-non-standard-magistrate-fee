class Event
  class Edit < Event
    def self.build(claim:, linked:, details:, current_user:)
      create(
        claim: claim,
        claim_version: claim.current_version,
        primary_user: current_user,
        linked_type: linked.fetch(:type),
        linked_id: linked.fetch(:id, nil),
        details: details,
      )
    end

    def notify
      FeedbackMailer.notify(
        user_email: 'test@test.com',
        user_rating: { 5 => 'Very satisfied' },
        user_feedback: 'good',
        application_env: application_environment
      ).deliver_later!
    end

    private

    def application_environment
      ENV.fetch('ENV', Rails.env).to_s
    end
  end
end
