class Claim < Submission
  validates :risk, inclusion: { in: %w[low medium high] }

  default_scope -> { where(application_type: APPLICATION_TYPES[:nsm]) }

  # open
  scope :pending_decision, -> { where.not(state: CLOSED_STATES) }

  # closed
  scope :decision_made, -> { where(state: CLOSED_STATES) }

  # your
  scope :pending_and_assigned_to, lambda { |user|
    pending_decision
      .joins(:assignments)
      .where(assignments: { user_id: user.id })
  }

  scope :auto_assignable, lambda { |user|
    where(state: [SUBMITTED, PROVIDER_UPDATED])
      .where.not(risk: :high)
      .where.missing(:assignments)
      .where.not(id: Event::Unassignment.where(primary_user_id: user.id).select(:submission_id))
  }

  STATES = (
    [
      SUBMITTED = 'submitted'.freeze,
      SENT_BACK = 'sent_back'.freeze,
      PROVIDER_UPDATED = 'provider_updated'.freeze,
    ] +
      CLOSED_STATES = (
        (ASSESSED_STATES = [
          GRANTED = 'granted'.freeze,
          PART_GRANT = 'part_grant'.freeze,
          REJECTED = 'rejected'.freeze
        ].freeze) +
        [EXPIRED = 'expired'.freeze]
      ).freeze
  ).freeze

  enum :state, STATES.to_h { [_1, _1] }

  def assigned_to?(user)
    assignments.find_by(user:)
  end

  def assessed?
    ASSESSED_STATES.include?(state)
  end

  def closed?
    CLOSED_STATES.include?(state)
  end

  def formatted_claimed_total
    formatted_summed_costs.dig(:gross_cost, :text)
  end

  def formatted_allowed_total
    return formatted_claimed_total if formatted_summed_costs[:allowed_gross_cost].blank? || granted_and_allowed_less_than_claim

    formatted_summed_costs.dig(:allowed_gross_cost, :text)
  end

  def any_adjustments?
    core_cost_summary.show_allowed?
  end

  def any_cost_changes?
    core_cost_summary.any_changed?
  end

  def any_cost_reductions?
    core_cost_summary.any_reduced?
  end

  def any_cost_increases?
    core_cost_summary.any_increased?
  end

  def adjustments_direction
    return :none unless any_cost_changes?
    return :mixed if any_cost_increases? && any_cost_reductions?
    return :down if any_cost_reductions?

    :up
  end

  private

  def granted_and_allowed_less_than_claim
    allowed_gross_cost = core_cost_summary.summed_fields[:allowed_gross_cost]
    gross_cost = core_cost_summary.summed_fields[:gross_cost]

    granted? && allowed_gross_cost < gross_cost
  end

  def formatted_summed_costs
    @formatted_summed_costs ||= core_cost_summary.formatted_summed_fields
  end

  def core_cost_summary
    @core_cost_summary ||= BaseViewModel.build(:core_cost_summary, self)
  end
end
