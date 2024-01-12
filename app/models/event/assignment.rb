class Event
  class Assignment < Event
    def self.build(crime_application:, current_user:)
      create(
        crime_application: crime_application,
        primary_user: current_user,
        crime_application_version: crime_application.current_version
      )
    end
  end
end
