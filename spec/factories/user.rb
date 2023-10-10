FactoryBot.define do
  factory :user do
    id { SecureRandom.uuid }
    email { 'test@test.com' }
  end
end
