FactoryBot.define do
  factory :event do
    trait :decision do
      event_type { 'decision' }
      details do
        {
          from: 'submitted',
          to: 'granted'
        }.with_indifferent_access
      end
    end

    trait :new_version do
      event_type { 'new_version' }
    end

    trait :note do
      event_type { 'note' }
      sequence(:details) do |i|
        { comment: "This is note: #{i}" }
      end
    end

    trait :edit_uplift do
      event_type { 'edit' }
      linked_type { 'letters_and_calls' }
      linked_id { 'letters' }
      details do
        {
          field: 'uplift',
          from: 95,
          to: 0,
          change: -95
        }.with_indifferent_access
      end
    end

    trait :edit_work_item_uplift do
      event_type { 'edit' }
      linked_type { 'work_item' }
      linked_id { '183ec754-d0fd-490c-b7a4-14e6951e6659' }
      details do
        {
          field: 'uplift',
          from: 20,
          to: 0,
          change: -20
        }.with_indifferent_access
      end
    end

    trait :edit_work_item_time_spent do
      event_type { 'edit' }
      linked_type { 'work_item' }
      linked_id { '183ec754-d0fd-490c-b7a4-14e6951e6659' }
      details do
        {
          field: 'time_spent',
          from: 171,
          to: 100,
          change: -71
        }.with_indifferent_access
      end
    end

    trait :edit_count do
      event_type { 'edit' }
      linked_type { 'letters_and_calls' }
      linked_id { 'letters' }
      details do
        {
          field: 'count',
          from: 10,
          to: 5,
          change: -5
        }.with_indifferent_access
      end
    end

    trait :decision do
      event_type { 'decision' }
      details do
        {
          field: 'state',
          from: 'submitted',
          to: 'granted',
          comment: 'grant it'
        }.with_indifferent_access
      end
    end
  end
end
