class Event
  class Unassignment < Event
    belongs_to :secondary_user, optional: true, class_name: 'User'

    def self.build(crime_application:, user:, current_user:, comment:)
      create(
        crime_application: crime_application,
        primary_user: user,
        secondary_user: user == current_user ? nil : current_user,
        crime_application_version: crime_application.current_version,
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
