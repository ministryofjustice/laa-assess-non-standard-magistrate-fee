class Event
  class DraftDecision < Event
    def self.construct(submission:, next_state:, comment:, current_user:)
      new(
        submission_version: submission.current_version,
        primary_user_id: current_user.id,
        details: {
          field: 'state',
          from: submission.state,
          to: next_state,
          comment: comment
        }
      )
    end
  end
end
