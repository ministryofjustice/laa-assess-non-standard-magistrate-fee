class Event
  class Edit < Event
    def self.build(submission:, linked:, details:, current_user:)
      submission.events << new(
        submission_version: submission.current_version,
        primary_user_id: current_user.id,
        linked_type: linked.fetch(:type),
        linked_id: linked.fetch(:id, nil),
        details: details,
      )
    end
  end
end
