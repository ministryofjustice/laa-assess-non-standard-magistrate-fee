FactoryBot.define do
  factory :role do
    user { nil }

    trait :supervisor do
      role_type { 'supervisor' }
    end

    trait :caseworker do
      role_type { 'caseworker' }
    end

    trait :viewer do
      role_type { 'viewer' }
    end
  end
end
