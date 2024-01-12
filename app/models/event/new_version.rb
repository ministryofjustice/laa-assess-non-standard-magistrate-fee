class Event
  class NewVersion < Event
    def self.build(crime_application:)
      create(crime_application: crime_application, crime_application_version: crime_application.current_version)
    end
  end
end
