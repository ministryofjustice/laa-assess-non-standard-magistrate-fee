class NotifyAppStore
  class MessageBuilder
    JSON_SCHEMA_VERSION = 1

    attr_reader :submission, :validate

    def initialize(submission:, validate: true)
      @submission = submission
      @validate = validate
    end

    def message
      {
        application_id: submission.id,
        json_schema_version: JSON_SCHEMA_VERSION,
        application_type: submission.application_type,
        application_state: submission.state,
        application: validated_data,
        events: submission.events.map(&:as_json),
        application_risk: submission.risk,
      }
    end

    def validated_data
      return submission.data unless validate

      service_type = Submission::APPLICATION_TYPES.invert[submission.application_type]
      issues = LaaCrimeFormsCommon::Validator.validate(service_type, submission.data)

      return submission.data if issues.none?

      raise "Validation issues for #{submission.id}: #{issues.to_sentence}"
    end
  end
end
