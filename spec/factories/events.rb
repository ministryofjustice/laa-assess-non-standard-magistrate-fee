class EventCreatable < Event
  class << self
    public :new
  end
end

FactoryBot.define do
  factory :event, class: 'EventCreatable' do
    transient do
      claim { nil }
    end
    submission { claim || create(:claim) }
    submission_version { submission.current_version }

    trait :decision do
      event_type { Event::Decision.to_s }
      details do
        {
          from: 'submitted',
          to: 'granted'
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
      event_type { Event::Edit.to_s }
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
      event_type { Event::Edit.to_s }
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
      event_type { Event::Edit.to_s }
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
      event_type { Event::Decision.to_s }
      details do
        {
          field: 'state',
          from: 'submitted',
          to: 'granted',
          comment: 'grant it'
        }
      end
    end

    trait :provider_updated do
      event_type { Event::ProviderUpdated.to_s }
      details do
        {
          comment: 'Added more info',
          corrected_info: %w[ufn case_contact]
        }
      end
    end
  end
end
