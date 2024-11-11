class Event
  class AutoDecision < Event
    def self.construct(submission:, previous_state:)
      create(
        submission: submission,
        submission_version: submission.current_version,
        details: {
          field: 'state',
          from: previous_state,
          to: submission.state
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
