module PriorAuthority
  class FakeAssess < ApplicationJob
    def perform(application_ids)
      PriorAuthorityApplication.where(id: application_ids, state: PriorAuthorityApplication::ASSESSABLE_STATES)
                               .find_each do |application|
        assess(application)
      end
    end

    def assess(application)
      case SecureRandom.rand(5)
      when 0
        grant(application)
      when 1
        part_grant(application)
      when 2
        reject(application)
      when 3
        request_further_info(application)
      when 4
        request_correction(application)
      else
        raise 'Unexpected randomness outcome - did someone mess up a refactor?'
      end
    end

    private

    def grant(application)
      PriorAuthority::DecisionForm.new(submission: application, current_user: User.first, pending_decision: 'granted').save
    end

    def part_grant(application)
      adjust(application)

      PriorAuthority::DecisionForm.new(
        submission: application,
        current_user: User.first,
        pending_decision: 'part_grant',
        pending_part_grant_explanation: Faker::Lorem.paragraph
      ).save
    end

    def adjust(submission)
      primary_quote = V1::Quote.build(:quote, submission, 'quotes').find(&:primary)
      item = BaseViewModel.build(:service_cost, submission, 'quotes').find { _1.id == primary_quote.id }
      current_user = User.first
      form = ServiceCostForm.new(submission:, item:, current_user:, **item.form_attributes)
      form.assign_attributes(
        items: Faker::Number.between(from: 1, to: 6),
        cost_per_item: Faker::Number.between(from: 1.0, to: 99.0).round(2),
        period: Faker::Number.between(from: 1, to: 300),
        cost_per_hour: Faker::Number.between(from: 1.0, to: 99.0).round(2),
        explanation: Faker::Lorem.paragraph,
      )

      form.save
    end

    def reject(application)
      PriorAuthority::DecisionForm.new(
        submission: application,
        current_user: User.first,
        pending_decision: 'rejected',
        pending_rejected_explanation: Faker::Lorem.paragraph
      ).save
    end

    def request_further_info(application)
      PriorAuthority::SendBackForm.new(
        submission: application,
        current_user: User.first,
        updates_needed: ['further_information'],
        further_information_explanation: Faker::Lorem.paragraph
      ).save
    end

    def request_correction(application)
      PriorAuthority::SendBackForm.new(
        submission: application,
        current_user: User.first,
        updates_needed: ['incorrect_information'],
        incorrect_information_explanation: Faker::Lorem.paragraph
      ).save
    end
  end
end
