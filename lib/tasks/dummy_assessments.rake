namespace :dummy_assessments do
  desc 'assess most pending assessments randomly'

  task create: :environment do
    PriorAuthorityApplication.where(state: PriorAuthorityApplication::ASSESSABLE_STATES)
                             .find_in_batches(batch_size: 100) do |batch|
      PriorAuthority::FakeAssess.new.perform(batch.map(&:id))
    end

    Claim.where.not(state: Claim::CLOSED_STATES)
         .find_in_batches(batch_size: 100) do |batch|
      Nsm::FakeAssess.new.perform(batch.map(&:id))
    end
  end
end
