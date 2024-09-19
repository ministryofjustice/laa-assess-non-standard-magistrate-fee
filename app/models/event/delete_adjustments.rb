class Event
  class DeleteAdjustments < Event
    def self.build(submission:, comment:, current_user:)
      create(
        submission: submission,
        submission_version: submission.current_version,
        primary_user: current_user,
        details: {
          comment:
        }
      )
    end
  end
end
