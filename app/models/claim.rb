class Claim < ApplicationRecord
  has_many :events, dependent: :destroy

  validates :risk, inclusion: { in: %w[low medium high] }
  validates :current_version, numericality: { only_integer: true, greater_than: 0 }

  scope :pending_decision, -> { where.not(state: MakeDecisionForm::STATES) }
  scope :decision_made, -> { where.not(state: 'submitted') }
  # TODO: - will add the filtering to current user once we have user assignment setup
  scope :your_claims, -> { where(state: 'submitted') }
  scope :unassigned_claims, -> { where(current_version: 1) }
end
