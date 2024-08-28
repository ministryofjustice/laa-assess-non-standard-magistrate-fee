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
end
