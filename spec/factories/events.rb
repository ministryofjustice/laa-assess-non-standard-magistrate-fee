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
          corrected_info: true
        }
      end
    end

    trait :prior_authority_send_back do
      initialize_with { PriorAuthority::Event::SendBack.new(attributes) }
      details do
        {
          comment: 'Added more info',
          corrected_info: true
        }
      end
    end

    trait :nsm_send_back do
      initialize_with { Nsm::Event::SendBack.new(attributes) }
      details do
        {
          comment: 'Give me more info',
        }
      end
    end
  end
end
