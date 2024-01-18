FactoryBot.define do
  factory :assignment do
    user factory: %i[caseworker]
    transient do
      claim { nil }
    end
    submission { claim || create(:claim) }
  end
end
