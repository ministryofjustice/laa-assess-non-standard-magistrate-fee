FactoryBot.define do
  factory :prior_authority_application do
    received_on { Date.yesterday }
    current_version { 1 }
    state { 'submitted' }
    json_schema_version { 1 }
    application_type { 'crm4' }
    data factory: :prior_authority_data
  end

  factory :prior_authority_data, class: Hash do
    initialize_with { attributes }
    laa_reference { 'LAA-123456' }
    firm_name { 'LegalCo' }
    client_name { 'Jane Doe' }
    additional_costs { [] }
  end

  factory :additional_cost, class: Hash do
    initialize_with { attributes }
    id { SecureRandom.uuid }
    time_spent { 60 }
    cost_per_hour { 32 }
    description { 'Translation services' }
  end
end
