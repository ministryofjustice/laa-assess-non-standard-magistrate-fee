class Event
  class NewVersion < Event
    def self.construct(submission:)
      # We notify the app store immediately of a new version, because its analytics mechanism
      # depends on having new version events available.
      create(submission: submission, submission_version: submission.current_version)
    end

    def body
      t('updated_body') if submission_version > 1
    end
  end
end
