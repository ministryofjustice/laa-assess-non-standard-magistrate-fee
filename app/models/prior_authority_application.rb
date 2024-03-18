class PriorAuthorityApplication < Submission
  default_scope -> { where(application_type: APPLICATION_TYPES[:prior_authority]) }

  STATES = [
    (PENDING_STATES = [
      SUBMITTED = 'submitted'.freeze,
      PROVIDER_UPDATED = 'provider_updated'.freeze
    ].freeze) +
      (ASSESSED_STATES = [
        GRANTED = 'granted'.freeze,
        PART_GRANT = 'part_grant'.freeze,
        REJECTED = 'rejected'.freeze,
        SENT_BACK = 'sent_back'.freeze
      ].freeze)
  ].freeze

  scope :pending_decision, -> { where(state: PENDING_STATES) }
  scope :decision_made, -> { where(state: ASSESSED_STATES) }
end
