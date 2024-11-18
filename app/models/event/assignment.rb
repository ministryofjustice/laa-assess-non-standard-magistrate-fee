class Event
  class Assignment < Event
    def self.construct(submission:, current_user:, comment: nil)
      new(
        primary_user_id: current_user.id,
        submission_version: submission.current_version,
        details: {
          comment:
        }
      )
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
