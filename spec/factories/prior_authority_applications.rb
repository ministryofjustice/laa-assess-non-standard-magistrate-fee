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
    ufn { '130324/001' }
    prison_law { false }
    provider do
      {
        'email' => 'provider@example.com',
        'description' => nil,
      }
    end
    firm_office do
      { 'name' => 'LegalCo' }
    end
    defendant do
      {
        'first_name' => 'Joe',
        'last_name' => 'Bloggs',
        'date_of_birth' => '1950-01-01'
      }
    end
    additional_costs { [] }
    solicitor do
      {
        'contact_full_name' => 'Jane Doe',
        'contact_email' => 'jane@doe.com'
      }
    end
    main_offence_id { 'robbery' }
    service_type { 'pathologist_report' }
    client_detained { false }
    subject_to_poca { false }
    prior_authority_granted { true }
    plea { 'guilty' }
    court_type { 'crown_court' }
    rep_order_date { '2023-01-02' }
    next_hearing_date { '2025-01-01' }
    quotes { [build(:primary_quote)] }

    trait :related_application do
      ufn { '111111/111' }
      firm_office do
        {
          'name' => 'LegalCo',
          'account_number' => '2B0N2B'
        }
      end
    end
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
    item_type { 'page' }
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
    document do
      {
        'file_name' => 'test.pdf',
        'file_path' => '123123123'
      }
    end

    trait :with_adjustments do
      cost_type { 'per_item' }
      items { 10 }
      item_type { 'item' }
      cost_per_item { '5.0' }
      cost_per_item_original { '10.0' }
      travel_time { 60 }
      travel_cost_per_hour { '100.0' }
      travel_cost_per_hour_original { '200.0' }
      adjustment_comment { 'caseworker service cost adjustment explanantion' }
      travel_adjustment_comment { 'caseworker travel cost adjustment explanantion' }

    end

    trait :per_hour do
      cost_type { 'per_hour' }
      cost_per_hour { '80.0' }
      cost_per_item { nil }
      item_type { nil }
      period { 420 }
    end

    trait :no_travel do
      travel_time { nil }
      travel_cost_per_hour { nil }
      travel_cost_reason { nil }
    end
  end

  factory :alternative_quote, class: Hash do
    initialize_with { attributes }
    id { SecureRandom.uuid }
    cost_type { 'per_hour' }
    cost_per_hour { '3.5' }
    cost_per_item { nil }
    items { nil }
    period { 180 }
    travel_time { 180 }
    travel_cost_per_hour { '100.0' }
    travel_cost_reason { nil }
    additional_cost_list { "Foo\nBar" }
    additional_cost_total { 100.0 }
    contact_full_name { 'ABC DEF' }
    organisation { 'ABC' }
    postcode { 'SW1 1AA' }
    primary { false }
    ordered_by_court { nil }
    related_to_post_mortem { nil }
    document { nil }
  end
end
