module AppStore
  class PayloadBuilder
    JSON_SCHEMA_VERSION = 1

    attr_reader :submission, :metadata

    def initialize(submission:, metadata:)
      @submission = submission
      @metadata = metadata
    end

    def as_json(*)
      {
        application_id: submission.id,
        json_schema_version: JSON_SCHEMA_VERSION,
        application_type: submission.application_type,
        application_state: submission.state,
        application: submission.data,
        events: submission.events.map(&:as_json),
        application_risk: submission.risk,
      }.merge(metadata)
    end
  end
end
