FactoryBot.define do
  factory :assignment do
    user factory: %i[caseworker]
    submission factory: :claim
  end
end
