class Event
  class Decision < Event
    def self.construct(submission:, previous_state:, comment:, current_user:)
      new(
        submission_version: submission.current_version,
        primary_user_id: current_user.id,
        details: {
          field: 'state',
          from: previous_state,
          to: submission.state,
          comment: comment
        }
      )
    end

    def title
      t("title.#{details.with_indifferent_access['to']}", **title_options)
    end

    private

    def title_options
      { state: details.with_indifferent_access['to'].tr('_', ' ') }
    end
  end
end
