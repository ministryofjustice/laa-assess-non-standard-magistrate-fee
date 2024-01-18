class Event
  class Unassignment < Event
    belongs_to :secondary_user, optional: true, class_name: 'User'

    def self.build(submission:, user:, current_user:, comment:)
      create(
        submission: submission,
        primary_user: user,
        secondary_user: user == current_user ? nil : current_user,
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
