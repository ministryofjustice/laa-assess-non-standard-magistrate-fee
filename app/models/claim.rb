class Claim < Submission
  validates :risk, inclusion: { in: %w[low medium high] }

  default_scope -> { where(application_type: APPLICATION_TYPES[:nsm]) }

  # open
  scope :pending_decision, -> { where.not(state: Nsm::MakeDecisionForm::STATES) }

  # closed
  scope :decision_made, -> { where(state: Nsm::MakeDecisionForm::STATES) }

  # your
  scope :pending_and_assigned_to, lambda { |user|
    pending_decision
      .joins(:assignments)
      .where(assignments: { user_id: user.id })
  }

  scope :unassigned, lambda { |user|
    pending_decision
      .where.missing(:assignments)
      .where.not(id: Event::Unassignment.where(primary_user_id: user.id).select(:submission_id))
  }

  def part_grant?
    state == Nsm::MakeDecisionForm::PART_GRANT
  end

  def editable_by?(user)
    !assessed? && assigned_to?(user)
  end

  def assigned_to?(user)
    assignments.find_by(user:)
  end

  def assessed?
    Nsm::MakeDecisionForm::STATES.include?(state)
  end

  def sent_back?
    state == Nsm::SendBackForm::SENT_BACK
  end

  def display_state?
    sent_back? || assessed?
  end

  def formatted_claimed_total
    summed_costs.dig(:gross_cost, :text)
  end

  def formatted_allowed_total
    return formatted_claimed_total if summed_costs[:allowed_gross_cost].blank?

    summed_costs.dig(:allowed_gross_cost, :text)
  end

  def any_adjustments?
    core_cost_summary.show_allowed?
  end

  private

  def summed_costs
    @summed_costs ||= core_cost_summary.summed_fields
  end

  def core_cost_summary
    @core_cost_summary ||= BaseViewModel.build(:core_cost_summary, self)
  end
end
