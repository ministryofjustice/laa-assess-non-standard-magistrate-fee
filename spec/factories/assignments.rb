FactoryBot.define do
  factory :assignment do
    user { build(:caseworker) }
    claim
  end
end
