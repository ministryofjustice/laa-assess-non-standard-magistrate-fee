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

  def last_updated_at
    # This method will always¹ return the same value as the app store
    # 'last_updated' value in its search results provided the following
    # always hold true:

    # - all and only Event::NOTIFYING_EVENTS trigger an app store update
    #   that is not accompanied by sending a new version to the app store
    # - the provider app never sends any events to the app store without
    #   also sending a new version
    # - any time a new version is synced from the app store, this triggers a
    #   NewVersion event which then gets sent BACK to the app store

    # The fallback to `updated_at` is for the edge case where somehow a submission
    # gets created without an accompanying NewVersion event

    # ¹ The exceptions are in the brief window between the app store receiving a new
    # version from the provider and the caseworker completing sending a NewVersion
    # event _back_ to the app store.
    events.notifying.maximum(:created_at) || updated_at
  end
end
