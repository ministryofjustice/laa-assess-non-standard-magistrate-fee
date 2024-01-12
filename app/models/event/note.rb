class Event
  class Note < Event
    def self.build(crime_application:, note:, current_user:)
      create(
        crime_application: crime_application,
        crime_application_version: crime_application.current_version,
        primary_user: current_user,
        details: {
          comment: note
        }
      )
    end
  end
end
