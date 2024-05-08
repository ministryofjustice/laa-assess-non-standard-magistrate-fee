module Nsm
  class FakeAssess < ApplicationJob
    def perform(claim_ids)
      Claim.where(id: claim_ids)
           .where.not(state: Nsm::MakeDecisionForm::STATES)
           .find_each do |claim|
        assess(claim)
      end
    end

    def assess(claim)
      case SecureRandom.rand(5)
      when 0
        grant(claim)
      when 1
        part_grant(claim)
      when 2
        reject(claim)
      when 3
        request_further_info(claim)
      when 4
        mark_provider_requested(claim)
      else
        raise 'Unexpected randomness outcome - did someone mess up a refactor?'
      end
    end

    private

    def grant(claim)
      Nsm::MakeDecisionForm.new(claim: claim, current_user: User.first, state: 'granted').save
    end

    def part_grant(claim)
      adjust(claim)

      Nsm::MakeDecisionForm.new(
        claim: claim,
        current_user: User.first,
        partial_comment: Faker::Lorem.paragraph,
        state: 'part_grant'
      ).save
    end

    def adjust(claim)
      items = BaseViewModel.build(:work_item, claim, 'work_items')
      item = items.sample

      form = WorkItemForm.new(
        claim: claim,
        item: item,
        uplift: 0,
        time_spent: Faker::Number.between(from: 1, to: 300),
        explanation: Faker::Lorem.paragraph,
        current_user: User.first,
        id: item.id
      )
      form.save
    end

    def reject(claim)
      Nsm::MakeDecisionForm.new(
        claim: claim,
        current_user: User.first,
        reject_comment: Faker::Lorem.paragraph,
        state: 'rejected'
      ).save
    end

    def request_further_info(claim)
      Nsm::SendBackForm.new(
        claim: claim,
        current_user: User.first,
        state: 'further_info',
        comment: Faker::Lorem.paragraph
      ).save
    end

    def mark_provider_requested(claim)
      Nsm::SendBackForm.new(
        claim: claim,
        current_user: User.first,
        state: 'provider_requested',
        comment: Faker::Lorem.paragraph
      ).save
    end
  end
end
