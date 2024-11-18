class Event
  class Unassignment < Event
    def self.construct(submission:, user:, current_user:, comment:)
      new(
        primary_user_id: user.id,
        secondary_user_id: user == current_user ? nil : current_user.id,
        submission_version: submission.current_version,
        details: {
          comment:
        }
      )
    end

    def secondary_user
      User.find_by(id: secondary_user_id)
    end

    def title
      if secondary_user_id
        t('title.secondary', display_name: secondary_user&.display_name)
      else
        t('title.self')
      end
    end
  end
end
