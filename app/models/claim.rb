class Claim < ApplicationRecord
  has_many :events, dependent: :destroy
  has_many :assignments, dependent: :destroy

  validates :risk, inclusion: { in: %w[low medium high] }
  validates :current_version, numericality: { only_integer: true, greater_than: 0 }

  scope :pending_decision, -> { where.not(state: MakeDecisionForm::STATES) }
  scope :decision_made, -> { where.not(state: 'submitted') }
  scope :your_claims, lambda { |user|
    joins(:assignments)
      .where(state: 'submitted', assignments: { user_id: user.id })
  }
  scope :unassigned_claims, lambda { |user|
    where.missing(:assignments)
         .where(state: 'submitted')
         .where.not(id: Event::Unassignment.where(primary_user_id: user.id).select(:claim_id))
  }
end
