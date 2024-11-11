class Event
  class Expiry < Event
    def self.construct(submission:)
      create(submission: submission, submission_version: submission.current_version)
    end
  end
end
