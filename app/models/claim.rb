class Claim < Submission
  validates :risk, inclusion: { in: %w[low medium high] }

  def editable?
    Nsm::MakeDecisionForm::STATES.exclude?(state)
  end

  def display_state?
    Nsm::SendBackForm::STATES.include?(state) || !editable?
  end

  def history_events
    events.select(&:historical?).sort_by(&:created_at)
  end
end
