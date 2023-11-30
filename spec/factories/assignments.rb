FactoryBot.define do
  factory :assignment do
    user factory: %i[caseworker]
    claim
  end
end
