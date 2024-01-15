class Claim < CrimeApplication
  validates :risk, inclusion: { in: %w[low medium high] }

  default_scope -> { where(application_type: APPLICATION_TYPES[:non_standard_magistrates_payment]) }

  def editable?
    NonStandardMagistratesPayment::MakeDecisionForm::STATES.exclude?(state)
  end

  def display_state?
    NonStandardMagistratesPayment::SendBackForm::STATES.include?(state) || !editable?
  end
end
