class BackFillNewVersionNotifications < ActiveRecord::Migration[7.1]
  def change
    # Unassessed submissions haven't been pushing their new version events to the app
    # store recently. Once they are assessed or sent back those events get synced,
    # so it's only the ones that are still awaiting assessment that could be out
    # of sync
    Submission.where(state: %w[submitted provider_updated]).find_each do |submission|
      last_new_version_event = submission.events.where(event_type: 'Event::NewVersion').order(:created_at).last
      last_new_version_event&.notify
    end
  end
end
