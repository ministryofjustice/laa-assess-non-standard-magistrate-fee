class Event
  class Assignment < Event
    def self.build(submission:, current_user:)
      submission.events << new(
        primary_user_id: current_user.id,
        submission_version: submission.current_version
      )
    end
  end
end
