class Event
  class Assignment < Event
    def self.build(submission:, current_user:)
      create(
        submission: submission,
        primary_user: current_user,
        submission_version: submission.current_version
      )
    end
  end
end
