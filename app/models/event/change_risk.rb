class Event
  class ChangeRisk < Event
    def self.build(crime_application:, explanation:, previous_risk_level:, current_user:)
      create(
        crime_application: crime_application,
        crime_application_version: crime_application.current_version,
        primary_user: current_user,
        details: {
          field: 'risk',
          from: previous_risk_level,
          to: crime_application.risk,
          comment: explanation
        }
      )
    end

    def title_options
      { risk: details['to'] }
    end
  end
end
