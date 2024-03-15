class Claim < Submission
  validates :risk, inclusion: { in: %w[low medium high] }

  default_scope -> { where(application_type: APPLICATION_TYPES[:nsm]) }

  scope :pending_decision, -> { where.not(state: Nsm::MakeDecisionForm::STATES) }
  scope :decision_made, -> { where(state: Nsm::MakeDecisionForm::STATES) }

  def editable?
    Nsm::MakeDecisionForm::STATES.exclude?(state)
  end

  def display_state?
    Nsm::SendBackForm::STATES.include?(state) || !editable?
  end
end
