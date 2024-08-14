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
      else
        leave_unassessed(claim)
      end
    end

    private

    def grant(claim)
      assign(claim)
      Nsm::MakeDecisionForm.new(claim: claim, current_user: claim.assignments.first.user, state: 'granted').save
    end

    def part_grant(claim)
      assign(claim)
      adjust(claim)

      Nsm::MakeDecisionForm.new(
        claim: claim,
        current_user: claim.assignments.first.user,
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
        current_user: claim.assignments.first.user,
        id: item.id,
        work_item_pricing: claim.data['work_item_pricing'],
        work_type_value: item.work_type.value,
      )
      form.save
    end

    def reject(claim)
      assign(claim)
      Nsm::MakeDecisionForm.new(
        claim: claim,
        current_user: claim.assignments.first.user,
        reject_comment: Faker::Lorem.paragraph,
        state: 'rejected'
      ).save
    end

    def request_further_info(claim)
      assign(claim)
      Nsm::SendBackForm.new(
        claim: claim,
        current_user: claim.assignments.first.user,
        comment: Faker::Lorem.paragraph
      ).save
    end

    def leave_unassessed(_)
      nil
    end

    def assign(claim)
      user = User.order('RANDOM()').first
      claim.assignments.create!(user:)
      ::Event::Assignment.build(submission: claim, current_user: user)
    end
  end
end
