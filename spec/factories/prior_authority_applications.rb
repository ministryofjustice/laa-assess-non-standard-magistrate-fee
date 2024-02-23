FactoryBot.define do
  factory :prior_authority_application do
    received_on { Date.yesterday }
    current_version { 1 }
    state { 'submitted' }
    json_schema_version { 1 }
    application_type { 'crm4' }
    data factory: :prior_authority_data, strategy: :build
  end

  factory :prior_authority_data, class: Hash do
    initialize_with { attributes }
    laa_reference { 'LAA-123456' }
    firm_office do
      { 'name' => 'LegalCo' }
    end
    defendant do
      {
        'first_name' => 'Joe',
        'last_name' => 'Bloggs',
      }
    end
    additional_costs { [] }
    service_type { 'pathologist_report' }
    court_type { 'crown_court' }
    rep_order_date { '2023-01-02' }
    quotes { [build(:primary_quote)] }
  end

  factory :additional_cost, class: Hash do
    initialize_with { attributes }
    id { SecureRandom.uuid }
    name { 'ABC' }
    description { 'ABC DEF' }
    unit_type { 'per_hour' }
    items { nil }
    cost_per_item { nil }
    cost_per_hour { '32.0' }
    period { 60 }
  end

  factory :primary_quote, class: Hash do
    initialize_with { attributes }
    id { SecureRandom.uuid }
    cost_type { 'per_item' }
    cost_per_hour { nil }
    cost_per_item { '3.5' }
    items { 7 }
    period { nil }
    travel_time { 180 }
    travel_cost_per_hour { '100.0' }
    travel_cost_reason { nil }
    additional_cost_list { nil }
    additional_cost_total { nil }
    contact_full_name { 'ABC DEF' }
    organisation { 'ABC' }
    postcode { 'SW1 1AA' }
    primary { true }
    ordered_by_court { nil }
    related_to_post_mortem { nil }
    document { nil }
  end
end
