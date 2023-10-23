FactoryBot.define do
  factory :claim do
    id { SecureRandom.uuid }
    risk { 'low' }
    received_on { Date.yesterday }
    current_version { 1 }
    state { 'submitted' }

    trait :with_version do
      versions { [build(:version)] }
    end
  end
end
