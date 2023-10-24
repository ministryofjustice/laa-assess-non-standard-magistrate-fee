class NotifyAppStore
  class MessageBuilder
    JSON_SCHEMA_VERSION = 1

    attr_reader :claim, :scorer

    def initialize(claim:)
      @claim = claim
    end

    def message
      {
        application_id: claim.id,
        json_schema_version: JSON_SCHEMA_VERSION,
        application_state: claim.state,
        application: claim.data,
        events: claim.events.map(&:as_json),
        application_risk: claim.risk,
      }
    end
  end
end
