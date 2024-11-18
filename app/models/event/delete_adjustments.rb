class Event
  class DeleteAdjustments < Event
    def self.construct(submission:, comment:, current_user:)
      new(
        submission_version: submission.current_version,
        primary_user_id: current_user.id,
        details: {
          comment:
        }
      )
    end
  end
end
