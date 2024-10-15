FactoryBot.define do
  factory :caseworker, class: 'User' do
    email { 'case.worker@test.com' }
    first_name { 'case' }
    last_name { 'worker' }
    auth_oid { SecureRandom.uuid }
    auth_subject_id { SecureRandom.uuid }
    roles { [build(:role, :caseworker)] }

    trait :deactivated do
      deactivated_at { Time.zone.now }
    end
  end

  factory :supervisor, class: 'User' do
    email { 'super.visor@test.com' }
    first_name { 'super' }
    last_name { 'visor' }
    auth_oid { SecureRandom.uuid }
    auth_subject_id { SecureRandom.uuid }
    roles { [build(:role, :supervisor)] }
  end

  factory :viewer, class: 'User' do
    email { 'readonly.viewer@test.com' }
    first_name { 'cannot' }
    last_name { 'edit' }
    auth_subject_id { SecureRandom.uuid }
    roles { [build(:role, :viewer)] }
  end
end
