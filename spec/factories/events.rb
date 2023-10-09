FactoryBot.define do
  factory :event do
    id { SecureRandom.uuid }
    claim
    claim_vesion { claim.version }

    trait :decision do
      event_type { Event::Decision.to_s }
      details do
        {
          from: 'submitted',
          to: 'grant'
        }
      end
    end

    trait :new_version do
      event_type { Event::NewVersion.to_s }
    end
  end
end
