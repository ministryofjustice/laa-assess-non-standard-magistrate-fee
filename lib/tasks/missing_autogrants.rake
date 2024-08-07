namespace :missing_autogrants do
  desc 'Generate app store command text for syncing of events'
  task :generate_update_command, [:submission_ids] => [:environment] do |t, args|
    file_path = Rails.root.join('tmp/task_output/').to_s
    FileUtils.mkdir_p(file_path) unless File.directory?(file_path)
    File.open("#{file_path}autogrant_commands_#{Time.now.to_i}", 'a') do |file|
      args[:submission_ids].split(',').each do |submission_id|
        working_submission = Submission.find(submission_id)
        if working_submission.present?
          autogrant_event = working_submission.events.find_by(event_type: 'Event::AutoDecision')
          if autogrant_event.present?
            print "Found event id: #{autogrant_event} for Submission: #{submission_id}"
            file.write("submission = Submission.find(#{submission_id})")
            file.write("::Submissions::UpdateService.add_events(submission, {events: [#{autogrant_event.as_json}]}, save: true)")
          end
        end
      end
    end
  end
end
