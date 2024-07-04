module PriorAuthority
  class FakeAssess < ApplicationJob
    def perform(application_ids)
      PriorAuthorityApplication.where(id: application_ids, state: PriorAuthorityApplication::ASSESSABLE_STATES)
                               .find_each do |application|
        assess(application)
      end
    end

    def assess(application)
      case SecureRandom.rand(6)
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
        leave_unassessed(application)
      end
    end

    private

    def grant(application)
      assign(application)
      PriorAuthority::DecisionForm.new(submission: application,
                                       current_user: application.assignments.first.user,
                                       pending_decision: 'granted').save
    end

    def part_grant(application)
      assign(application)
      adjust(application)

      PriorAuthority::DecisionForm.new(
        submission: application,
        current_user: application.assignments.first.user,
        pending_decision: 'part_grant',
        pending_part_grant_explanation: Faker::Lorem.paragraph
      ).save
    end

    def adjust(submission)
      primary_quote = V1::Quote.build(:quote, submission, 'quotes').find(&:primary)
      item = BaseViewModel.build(:service_cost, submission, 'quotes').find { _1.id == primary_quote.id }
      current_user = submission.assignments.first.user
      form = ServiceCostForm.new(submission:, item:, current_user:, **item.form_attributes)
      form.assign_attributes(fake_adjustment_attributes)
      form.save
    end

    def fake_adjustment_attributes
      {
        items: Faker::Number.between(from: 1, to: 6),
        cost_per_item: Faker::Number.between(from: 1.0, to: 99.0).round(2),
        period: Faker::Number.between(from: 1, to: 300),
        cost_per_hour: Faker::Number.between(from: 1.0, to: 99.0).round(2),
        explanation: Faker::Lorem.paragraph,
      }
    end

    def reject(application)
      assign(application)
      PriorAuthority::DecisionForm.new(
        submission: application,
        current_user: application.assignments.first.user,
        pending_decision: 'rejected',
        pending_rejected_explanation: Faker::Lorem.paragraph
      ).save
    end

    def request_further_info(application)
      assign(application)
      PriorAuthority::SendBackForm.new(
        submission: application,
        current_user: application.assignments.first.user,
        updates_needed: ['further_information'],
        further_information_explanation: Faker::Lorem.paragraph
      ).save
    end

    def request_correction(application)
      assign(application)
      PriorAuthority::SendBackForm.new(
        submission: application,
        current_user: application.assignments.first.user,
        updates_needed: ['incorrect_information'],
        incorrect_information_explanation: Faker::Lorem.paragraph
      ).save
    end

    def leave_unassessed(_)
      nil
    end

    def assign(application)
      user = User.order('RANDOM()').first
      application.assignments.create!(user:)
      ::Event::Assignment.build(submission: application, current_user: user)
    end
  end
end
