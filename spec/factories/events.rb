class EventCreatable < Event
  class << self
    public :new
  end
end

FactoryBot.define do
  factory :event, class: 'EventCreatable' do
    id { SecureRandom.uuid }
    claim
    claim_version { claim.current_version }

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

    trait :note do
      event_type { Event::Note.to_s }
      sequence(:details) do |i|
        "This is note: #{i}"
      end
    end
  end
end
