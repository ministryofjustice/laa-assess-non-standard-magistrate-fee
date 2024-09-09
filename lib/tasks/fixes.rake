namespace :fixes do
  desc "Amend a contact email address. Typically because user has added a valid but undeliverable address"
  task :update_contact_email, [:id, :new_contact_email] => :environment do |_, args|
    submission = Submission.find(args[:id])

    STDOUT.print "This will update #{submission.data['laa_reference']}'s contact email, \"#{submission.data['solicitor']['contact_email'] || 'nil'}\", to \"#{args[:new_contact_email]}\": Are you sure? (y/n): "
    input = STDIN.gets.strip

    if input.downcase.in?(['yes','y'])
      print 'updating...'
      submission.data['solicitor']['contact_email'] = args[:new_contact_email]
      submission.save!(touch: false)
      puts "#{submission.data['laa_reference']}'s contact email is now #{submission.reload.data['solicitor']['contact_email']}"
    end
  end

  desc "Set LAA reference to correct values"
  task fix_mismatched_references: :environment do
    records = [
      {submission_id: '', laa_reference: ''},
      {submission_id: '', laa_reference: ''}
    ]

    records.each do |record|
      id = record['submission_id']
      new_reference = record['laa_reference']
      submission = Submission.find(id)
      if submission
        application_to_fix = submission.application
        old_reference = application_to_fix['laa_reference']
        application_to_fix['laa_reference'] = new_reference
        submission.application = application_to_fix
        submission.save!(touch: false)
        puts "Submission: #{id} LAA reference updated from #{old_reference} to #{new_reference}"
      else
        puts "Submission: #{id} could not be found"
      end
    end
  end
end
