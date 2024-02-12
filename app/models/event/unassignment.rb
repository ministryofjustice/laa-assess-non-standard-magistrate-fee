class Event
  class Unassignment < Event
    def self.build(submission:, user:, current_user:, comment:)
      submission.events << new(
        primary_user_id: user.id,
        secondary_user_id: user == current_user ? nil : current_user.id,
        submission_version: submission.current_version,
        details: {
          comment:
        }
      )
    end

    def title
      if secondary_user_id
        t('title.secondary', display_name: secondary_user.display_name)
      else
        t('title.self')
      end
    end
  end
end
