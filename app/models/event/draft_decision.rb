class Event
  class DraftDecision < Event
    def self.build(submission:, next_state:, comment:, current_user:)
      create!(
        submission: submission,
        submission_version: submission.current_version,
        primary_user: current_user,
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
