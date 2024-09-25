FactoryBot.define do
  factory :disbursement, class: Hash do
    initialize_with { attributes }
    id { SecureRandom.uuid }
    details { 'my disbursement' }
    miles { '100.0' }
    pricing { 0.45 }
    vat_rate { 0.2 }
    vat_amount { 9.0 }
    prior_authority { 'yes' }
    other_type { nil }
    disbursement_date { Date.current.iso8601 }
    disbursement_type { 'car' }
    total_cost_without_vat { 45.0 }
  end
end
