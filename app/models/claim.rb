class Claim < Submission
  validates :risk, inclusion: { in: %w[low medium high] }

  default_scope -> { where(application_type: APPLICATION_TYPES[:nsm]) }

  scope :pending_decision, -> { where.not(state: Nsm::MakeDecisionForm::STATES) }
  scope :decision_made, -> { where(state: Nsm::MakeDecisionForm::STATES) }
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

  def editable?
    Nsm::MakeDecisionForm::STATES.exclude?(state)
  end

  def display_state?
    Nsm::SendBackForm::STATES.include?(state) || !editable?
  end
end
