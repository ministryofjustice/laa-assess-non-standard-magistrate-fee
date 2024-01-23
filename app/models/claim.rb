class Claim < Submission
  validates :risk, inclusion: { in: %w[low medium high] }

  default_scope -> { where(application_type: APPLICATION_TYPES[:nsm]) }

  def editable?
    Nsm::MakeDecisionForm::STATES.exclude?(state)
  end

  def display_state?
    Nsm::SendBackForm::STATES.include?(state) || !editable?
  end
end
