class Event
  class Edit < Event
    def self.construct(submission:, linked:, details:, current_user:)
      new(
        submission_version: submission.current_version,
        primary_user_id: current_user.id,
        linked_type: linked.fetch(:type),
        linked_id: linked.fetch(:id, nil),
        details: details,
      )
    end
  end
end
