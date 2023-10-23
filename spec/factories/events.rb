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
        { comment: "This is note: #{i}" }
      end
    end

    trait :edit_uplift do
      event_type { Event::Edit.to_s }
      linked_type { 'letters' }
      details do
        {
          field: 'uplift',
          from: 95,
          to: 0,
          change: -95
        }
      end
    end

    trait :edit_count do
      event_type { Event::Edit.to_s }
      linked_type { 'letters' }
      details do
        {
          field: 'count',
          from: 10,
          to: 5,
          change: -5
        }
      end
    end
  end
end
