class Claim < ApplicationRecord
  has_many :events, dependent: :destroy
  has_many :assignments
  has_many :current_assignments, -> { where(created_at: (..Time.now), end_at: nil) }, class_name: 'Assignment'
  has_many :unassignments, -> { where.not(end_at: nil) }, class_name: 'Assignment'

  validates :risk, inclusion: { in: %w[low medium high] }
  validates :current_version, numericality: { only_integer: true, greater_than: 0 }

  scope :pending_decision, -> { where.not(state: MakeDecisionForm::STATES) }
  scope :decision_made, -> { where.not(state: 'submitted') }
  # TODO: - will add the filtering to current user once we have user assignment setup
  scope :your_claims, -> (user) do
    joins(:current_assignments)
    .where(state: 'submitted', assignments: { user_id: user.id })
    .distinct
  end
  scope :unassigned_claims, -> (user) do
    left_joins(:current_assignments)
    .where(state: 'submitted', assignments: { id: nil })
    .where.not(id: Claim.joins(:unassignments).where(assignments: { user_id: user.id }))
  end
end
