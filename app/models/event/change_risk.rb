class Event
  class ChangeRisk < Event
    def self.build(submission:, explanation:, previous_risk_level:, current_user:)
      create(
        submission: submission,
        submission_version: submission.current_version,
        primary_user: current_user,
        details: {
          field: 'risk',
          from: previous_risk_level,
          to: submission.risk,
          comment: explanation
        }
      )
    end

    def title_options
      { risk: details['to'] }
    end
  end
end
