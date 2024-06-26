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
      ).tap(&:notify)
    end

    def title
      if details['comment'].present?
        t('manual_title', caseworker: primary_user.display_name)
      else
        t('auto_title')
      end
    end
  end
end
