module PriorAuthority
  module Event
    class SendBack < ::Event
      def self.construct(submission:, updates_needed:, comments:, current_user:)
        new(
          submission_version: submission.current_version,
          primary_user_id: current_user.id,
          details: {
            updates_needed:,
            comments:
          }
        )
      end
    end
  end
end
