class Event
  class Decision < Event
    def self.build(submission:, previous_state:, comment:, current_user:)
      create(
        submission: submission,
        submission_version: submission.current_version,
        primary_user: current_user,
        details: {
          field: 'state',
          from: previous_state,
          to: submission.state,
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
