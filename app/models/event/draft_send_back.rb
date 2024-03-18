class Event
  class DraftSendBack < Event
    def self.build(submission:, comment:, current_user:)
      create!(
        submission: submission,
        submission_version: submission.current_version,
        primary_user: current_user,
        details: {
          field: 'state',
          from: submission.state,
          to: 'send_back',
          comment: comment
        }
      )
    end
  end
end
