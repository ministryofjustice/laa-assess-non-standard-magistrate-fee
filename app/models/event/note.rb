class Event
  class Note < Event
    def self.build(submission:, note:, current_user:)
      submission.events << new(
        submission_version: submission.current_version,
        primary_user_id: current_user.id,
        details: {
          comment: note
        }
      )
    end
  end
end
