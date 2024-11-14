class Event
  class ChangeRisk < Event
    def self.construct(submission:, explanation:, previous_risk_level:, current_user:)
      new(
        submission_version: submission.current_version,
        primary_user_id: current_user.id,
        details: {
          field: 'risk',
          from: previous_risk_level,
          to: submission.risk,
          comment: explanation
        }
      )
    end

    def title_options
      { risk: details.with_indifferent_access['to'] }
    end
  end
end
