class Event
  class Decision < Event
    def self.build(crime_application:, previous_state:, comment:, current_user:)
      create(
        crime_application: crime_application,
        crime_application_version: crime_application.current_version,
        primary_user: current_user,
        details: {
          field: 'state',
          from: previous_state,
          to: crime_application.state,
          comment: comment
        }
      )
    end

    def title
      t("title.#{details['to']}", **title_options)
    end

    private

    def title_options
      { state: details['to'].tr('_', ' ') }
    end
  end
end
