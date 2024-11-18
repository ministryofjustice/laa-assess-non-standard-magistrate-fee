FactoryBot.define do
  factory :event, class: 'Event' do
    transient do
      comment { nil }
      claim { nil }
    end
    submission { claim || build(:claim) }
    submission_version { submission.current_version }

    trait :decision do
      initialize_with { Event::Decision.new(attributes) }
      details do
        {
          from: 'submitted',
          to: 'granted'
        }
      end
    end

    trait :auto_decision do
      initialize_with { Event::AutoDecision.new(attributes) }
      details do
        {
          from: 'submitted',
          to: 'auto_grant'
        }
      end
    end

    trait :assignment do
      initialize_with { Event::Assignment.new(attributes) }
      details do
        {
          comment:
        }
      end
    end

    trait :unassignment do
      initialize_with { Event::Unassignment.new(attributes) }
      details do
        {
          comment:
        }
      end
    end

    trait :new_version do
      initialize_with { Event::NewVersion.new(attributes) }
    end

    trait :note do
      initialize_with { Event::Note.new(attributes) }
      sequence(:details) do |i|
        { comment: "This is note: #{i}" }
      end
    end

    trait :edit_uplift do
      initialize_with { Event::Edit.new(attributes) }
      linked_type { 'letters_and_calls' }
      linked_id { 'letters' }
      details do
        {
          field: 'uplift',
          from: 95,
          to: 0,
          change: -95
        }
      end
    end

    trait :edit_work_item_uplift do
      initialize_with { Event::Edit.new(attributes) }
      linked_type { 'work_item' }
      linked_id { '183ec754-d0fd-490c-b7a4-14e6951e6659' }
      details do
        {
          field: 'uplift',
          from: 20,
          to: 0,
          change: -20
        }
      end
    end

    trait :edit_work_item_time_spent do
      initialize_with { Event::Edit.new(attributes) }
      linked_type { 'work_item' }
      linked_id { '183ec754-d0fd-490c-b7a4-14e6951e6659' }
      details do
        {
          field: 'time_spent',
          from: 171,
          to: 100,
          change: -71
        }
      end
    end

    trait :edit_count do
      initialize_with { Event::Edit.new(attributes) }
      linked_type { 'letters_and_calls' }
      linked_id { 'letters' }
      details do
        {
          field: 'count',
          from: 10,
          to: 5,
          change: -5
        }
      end
    end

    trait :decision do
      initialize_with { Event::Decision.new(attributes) }
      details do
        {
          field: 'state',
          from: 'submitted',
          to: 'granted',
          comment: 'grant it'
        }
      end
    end

    trait :part_granted do
      initialize_with { Event::Decision.new(attributes) }
      details do
        {
          field: 'state',
          from: 'submitted',
          to: 'part_grant',
          comment: 'Allowing in part'
        }
      end
    end

    trait :provider_updated do
      initialize_with { Event::ProviderUpdated.new(attributes) }
      details do
        {
          comment: 'Added more info',
          corrected_info: %w[ufn case_contact]
        }
      end
    end

    trait :prior_authority_send_back do
      initialize_with { PriorAuthority::Event::SendBack.new(attributes) }
      details do
        {
          comment: 'Added more info',
          corrected_info: %w[ufn case_contact]
        }
      end
    end
  end
end
