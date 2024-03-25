module PriorAuthority
  module Event
    class SendBack < ::Event
      def self.build(submission:, updates_needed:, comments:, current_user:)
        create!(
          submission: submission,
          submission_version: submission.current_version,
          primary_user: current_user,
          details: {
            updates_needed:,
            comments:
          }
        )
      end
    end
  end
end
