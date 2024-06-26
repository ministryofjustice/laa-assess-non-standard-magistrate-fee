class SendMissingEvents < ActiveRecord::Migration[7.1]
  def change
    # send across any missing events that we want for reporting
    Event.joins(:submission)
         .where(event_type: %[Event::Assignment Event::Unassignment Event::NewVersion])
         .where(submission: { state: %[submitted provider_updated] })
         .each { NotifyEventAppStore.perform_later(event: _1) }
  end
end
