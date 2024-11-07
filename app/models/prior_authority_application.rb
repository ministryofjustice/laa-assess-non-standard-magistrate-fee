class PriorAuthorityApplication < Submission
  default_scope -> { where(application_type: APPLICATION_TYPES[:prior_authority]) }

  STATES = (
    (ASSESSABLE_STATES = [
      SUBMITTED = 'submitted'.freeze,
      PROVIDER_UPDATED = 'provider_updated'.freeze
    ].freeze) +
      (ASSESSED_STATES = [
        GRANTED = 'granted'.freeze,
        PART_GRANT = 'part_grant'.freeze,
        REJECTED = 'rejected'.freeze,
        AUTO_GRANT = 'auto_grant'.freeze
      ].freeze) +
      [SENT_BACK = 'sent_back'.freeze,
       EXPIRED = 'expired'.freeze]
  ).freeze

  enum :state, STATES.to_h { [_1, _1] }
end
