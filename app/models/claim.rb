class Claim < ApplicationRecord
  has_many :events, dependent: :destroy
  has_many :assignments

  validates :risk, inclusion: { in: %w[low medium high] }
  validates :current_version, numericality: { only_integer: true, greater_than: 0 }

  scope :pending_decision, -> { where.not(state: MakeDecisionForm::STATES) }
  scope :decision_made, -> { where.not(state: 'submitted') }
  scope :your_claims, -> (user) do
    joins(:assignments)
    .where(state: 'submitted', assignments: { user_id: user.id })
  end
  scope :unassigned_claims, -> (user) do
    left_joins(:assignments)
    .where(state: 'submitted', assignments: { id: nil })
    .where.not(id: Event::Unassignment.where(primary_user_id: user.id).select(:claim_id))
  end
end
