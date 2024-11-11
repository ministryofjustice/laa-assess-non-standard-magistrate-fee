class Event
  class Note < Event
    def self.construct(submission:, note:, current_user:)
      create(
        submission: submission,
        submission_version: submission.current_version,
        primary_user: current_user,
        details: {
          comment: note
        }
      )
    end
  end
end
