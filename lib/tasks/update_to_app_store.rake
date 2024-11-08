namespace :update_to_app_store do
  desc 'Re-update events for a list of submissions by id'
  task :sync_autogrant_events, [:ids] => [:environment] do |t, args|
    args[:ids].split(',').each do |submission_id|
      working_submission = Submission.find(submission_id)
      if working_submission.present?
        autogrant_event = working_submission.events.find_by(event_type: 'Event::AutoDecision')
        if autogrant_event.present?
          print "Syncing autogrant events to app store for Submission: #{submission_id}"
          NotifyEventAppStore.perform_now(event: autogrant_event)
        end
      end
    end
  end
end
