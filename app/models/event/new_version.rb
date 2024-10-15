class Event
  class NewVersion < Event
    def self.build(submission:)
      create(submission: submission, submission_version: submission.current_version)
    end

    def body
      t('updated_body') if submission_version > 1
    end
  end
end
