class CrimeApplication < ApplicationRecord
  APPLICATION_TYPES = {
    non_standard_magistrates_payment: 'crm7',
    prior_authority: 'crm4',
  }.freeze

  has_many :events, dependent: :destroy
  has_many :assignments, dependent: :destroy

  validates :current_version, numericality: { only_integer: true, greater_than: 0 }
  validates :application_type, inclusion: { in: APPLICATION_TYPES.values }

  scope :pending_decision, -> { where.not(state: MakeDecisionForm::STATES) }
  scope :decision_made, -> { where(state: MakeDecisionForm::STATES) }
  scope :your_claims, lambda { |user|
    pending_decision
      .joins(:assignments)
      .where(assignments: { user_id: user.id })
  }
  scope :unassigned_claims, lambda { |user|
    pending_decision
      .where.missing(:assignments)
      .where.not(id: Event::Unassignment.where(primary_user_id: user.id).select(:crime_application_id))
      .order(:created_at)
  }

  def editable?
    MakeDecisionForm::STATES.exclude?(state)
  end

  def display_state?
    SendBackForm::STATES.include?(state) || !editable?
  end
end
