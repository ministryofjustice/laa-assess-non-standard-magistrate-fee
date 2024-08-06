namespace :update_to_app_store do
  desc 'Re-update events for a list of submissions by id'
  task :fix_events, [:ids] => [:environment] do |t, args|
    id_array = args[:ids].split(',')
    id_array.each do |submission_id| do
      working_submission = Submission.find(submission_id)
      if working_submission.present?
        print "Syncing events to app store for submission: #{submission_id}"
        NotifyAppStore.notify(MessageBuilder.new(submission: working_submission))
      end
    end
  end
end
