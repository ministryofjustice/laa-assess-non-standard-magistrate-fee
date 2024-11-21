class PriorAuthorityApplication < Submission
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
end
