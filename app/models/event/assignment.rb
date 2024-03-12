class Event
  class Assignment < Event
    def self.build(submission:, current_user:, comment: nil)
      create(
        submission: submission,
        primary_user: current_user,
        submission_version: submission.current_version,
        details: {
          comment:
        }
      )
    end
  end
end
