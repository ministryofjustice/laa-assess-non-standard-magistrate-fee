FactoryBot.define do
  factory :access_log do
    user factory: %i[caseworker]
    submission_id { '123123123' }
    action { 'show' }
    controller { 'claim' }
    path { '/nsm/claims/show/123123123' }
    secondary_id { nil }
  end
end
