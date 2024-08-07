namespace :missing_autogrants do
  desc 'Generate app store command text for syncing of events'
  task :generate_update_command, [:submission_ids] => [:environment] do |t, args|
    File.open("../../tmp/autogrant_commands_#{Time.now.to_i}", 'a') do |file|
      args[:submission_ids].split(',').each do |submission_id|
        working_submission = Submission.find(submission_id)
        if working_submission.present?
          autogrant_event = working_submission.events.find_by(event_type: 'Event::AutoDecision')
          if autogrant_event.present?
            file.write("submission = Submission.find(#{submission_id})")
            file.write("::Submissions::UpdateService.add_events(submission, {events: [#{autogrant_event.as_json}]}, save: true)")
          end
        end
      end
    end
  end
end
