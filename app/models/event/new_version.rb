class Event
  class NewVersion < Event
    def self.build(submission:)
      submission.events << new(submission_version: submission.current_version)
    end
  end
end
