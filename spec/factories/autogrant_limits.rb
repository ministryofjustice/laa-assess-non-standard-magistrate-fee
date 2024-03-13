FactoryBot.define do
  factory :limits, class: 'AutograntLimit' do
    service { 'pathologist_report' }
    start_date { Date.new(2023, 1, 1) }
    unit_type { 'per_item' }
    max_units { 4 }
    max_rate_london { 80.0 }
    max_rate_non_london { 100.0 }
    travel_rate_london { 0.0 }
    travel_rate_non_london { 0.0 }
    travel_hours { 0 }

    trait :travel do
      travel_rate_london { 15 }
      travel_rate_non_london { 20 }
      travel_hours { 4 }
    end
  end
end
