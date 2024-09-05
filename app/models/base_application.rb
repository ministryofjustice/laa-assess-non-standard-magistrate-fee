class BaseApplication < Submission
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

  scope :open, -> { where(state: ASSESSABLE_STATES + [SENT_BACK]) }
  scope :closed, -> { where(state: ASSESSED_STATES + [EXPIRED]) }
  scope :open_and_assigned_to, lambda { |user|
    open.joins(:assignments).where(assignments: { user_id: user.id })
  }
  scope :assignable, lambda { |user|
    where(state: ASSESSABLE_STATES)
      .where.missing(:assignments)
      .where.not(id: Event::Unassignment.where(primary_user_id: user.id).select(:submission_id))
  }
end
