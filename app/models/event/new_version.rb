class Event
  class NewVersion < Event
    def self.build(submission:)
      create(submission: submission, submission_version: submission.current_version)
        .tap(&:notify)
    end
  end
end
