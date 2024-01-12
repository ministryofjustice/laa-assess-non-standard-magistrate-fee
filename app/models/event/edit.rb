class Event
  class Edit < Event
    def self.build(crime_application:, linked:, details:, current_user:)
      create(
        crime_application: crime_application,
        crime_application_version: crime_application.current_version,
        primary_user: current_user,
        linked_type: linked.fetch(:type),
        linked_id: linked.fetch(:id, nil),
        details: details,
      )
    end
  end
end
