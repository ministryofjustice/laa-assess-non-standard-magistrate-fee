# require 'file_utils'

namespace :custom_seeds do
  desc "Store see data down to a JSON file"
  task :store, [:claim_id]  => :environment  do |t, args|
    claim = Claim.find_by(id: args.claim_id)

    unless claim
      puts "Count not find claim to store with ID: #{args.claim_id}"
      exit
    end

    FileUtils.mkdir_p(Rails.root.join("db/seeds/#{args.claim_id}"))
    File.open(Rails.root.join("db/seeds/#{args.claim_id}/claim.json"), 'w') do |f|
      f.puts claim.to_json
    end
    File.open(Rails.root.join("db/seeds/#{args.claim_id}/version.json"), 'w') do |f|
      f.puts claim.current_version_record.to_json
    end

    puts "Claim successfully stored: #{claim.id}"
  end

  task load: :environment do
    case_worker = User.find_or_initialize_by(email: 'case.worker@test.com')
    case_worker.update(
      first_name: 'case',
      last_name: 'worker',
      role: 'caseworker',
      auth_oid: SecureRandom.uuid,
      auth_subject_id: SecureRandom.uuid,
    )

    case_worker = User.find_or_initialize_by(email: 'super.visor@test.com')
    case_worker.update(
      first_name: 'super',
      last_name: 'visor',
      role: 'supervisor',
      auth_oid: SecureRandom.uuid,
      auth_subject_id: SecureRandom.uuid,
    )

    Dir[Rails.root.join("db/seeds/*")].each do |path|
      claim_id = path.split('/').last
      puts "Processing import for claim: #{claim_id}"

      begin
        claim_hash = JSON.parse(File.read("#{path}/claim.json"))
        version_hash = JSON.parse(File.read("#{path}/version.json"))



        claim = Claim.find_by(id: claim_id)

        if claim
          claim.events.delete_all
          claim.versions.delete_all
          claim.delete
        end

        claim = Claim.create(claim_hash)
        claim.versions.create(version_hash)
        Event::NewVersion.build(claim:)

        # TODO: add an assignment event
      rescue => e
        puts "Error processing import for claim: #{claim_id}\n"
        puts e.inspect
      end
    end

  end
end