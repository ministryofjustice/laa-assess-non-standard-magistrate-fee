FactoryBot.define do
  factory :assignment do
    user factory: %i[caseworker]
    transient do
      claim { nil }
    end
    crime_application { claim || create(:claim) }
  end
end
