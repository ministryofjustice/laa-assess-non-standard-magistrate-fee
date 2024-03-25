class Submission < ApplicationRecord
  APPLICATION_TYPES = {
    nsm: 'crm7',
    prior_authority: 'crm4',
  }.freeze

  has_many :events, dependent: :destroy
  has_many :assignments, dependent: :destroy

  validates :current_version, numericality: { only_integer: true, greater_than: 0 }
  validates :application_type, inclusion: { in: APPLICATION_TYPES.values }

  def namespace
    Submission::APPLICATION_TYPES.invert[application_type].to_s.camelcase.constantize
  end

  def latest_decision_event
    events.latest_decision
  end

  def latest_provider_update_event
    events.latest_provider_update
  end
end
