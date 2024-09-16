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

  def last_updated_at
    # This method will attempts to return the same value as the app store
    # 'last_updated' attribute in its search results payload.

    # The app store last_updated is incremented every time an event is sent to the app store.
    # (It is also incremented when a new version is sent, but those are always accompanied by
    # new events so we can effectively ignore that.)
    # Some events created in the caseworker app are not synced immediately, so we ignore them,
    # safe in the knowledge that when they are eventually synced to the app store, so too
    # will be some other events that will be more recent.
    # E.g. a Note event will never be sent to the app store except once a noted
    # submission has been assessed or sent back, which will trigger its own events.
    # So we can guarantee that the latest event in the app store will never be a Note event,
    # meaning we can disregard those when calculating the last_updated value
    events.non_local.maximum(:created_at) || updated_at
  end
end
