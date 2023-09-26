FactoryBot.define do
  factory :caseworker, class: User do
    id { SecureRandom.uuid }
    email { 'case.worker@test.com' }
    first_name { 'case' }
    last_name { 'worker' }
    role { 'caseworker' }
    auth_oid { SecureRandom.uuid }
    auth_subject_id { SecureRandom.uuid }
  end

  factory :supervisor, class: User do
    id { SecureRandom.uuid }
    email { 'super.visor@test.com' }
    first_name { 'super' }
    last_name { 'visor' }
    role { 'supervisor' }
    auth_oid { SecureRandom.uuid }
    auth_subject_id { SecureRandom.uuid }
  end
end
