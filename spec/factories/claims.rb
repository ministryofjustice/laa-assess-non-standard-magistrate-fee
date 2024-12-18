FactoryBot.define do
  factory :claim do
    id { SecureRandom.uuid }
    risk { 'low' }
    created_at { Date.yesterday }
    current_version { 1 }
    state { 'submitted' }
    json_schema_version { 1 }
    application_type { 'crm7' }
    assigned_user_id { nil }
    data factory: :nsm_data, strategy: :build

    after(:build) do |claim|
      claim.data = claim.data.deep_stringify_keys.with_indifferent_access
    end

    trait :with_assignment do
      assigned_user_id { SecureRandom.uuid }
    end
  end

  factory :nsm_data, class: Hash do
    initialize_with { attributes }
    laa_reference { 'LAA-FHaMVK' }
    submitter do
      {
        'email' => 'provider@example.com',
        'description' => nil
      }
    end
    send_by_post { nil }
    ufn { '123456/001' }
    cntp_order { nil }
    cntp_date { nil }
    assigned_counsel { 'no' }
    unassigned_counsel { 'yes' }
    agent_instructed { 'no' }
    remitted_to_magistrate { 'no' }
    reasons_for_claim { ['counsel_or_agent_assigned'] }
    supplemental_claim { 'no' }
    preparation_time { 'no' }
    work_before { 'no' }
    work_after { 'no' }
    work_completed_date { '2024-01-01' }
    has_disbursements { 'no' }
    is_other_info { 'no' }
    youth_court { 'no' }
    hearing_outcome { 'CP05' }
    claim_type { 'non_standard_magistrate' }
    rep_order_date { '2024-10-13' }
    matter_type { '10' }
    concluded { 'no' }
    answer_equality { 'no' }
    stage_reached { 'prog' }
    court { 'youth_court' }
    work_item_pricing do
      {
        'waiting' => -1,
        'preparation' => -1,
        'attendance_without_counsel' => -1,
        'attendance_with_counsel' => -1,
        'advocacy' => -1,
      }
    end
    cost_summary do
      {
        'profit_costs' => {
          'gross_cost' => '120.0',
          'net_cost' => '100',
          'vat' => '20.0'
        },
        'disbursements' => {
          'gross_cost' => '120.0',
          'net_cost' => '100',
          'vat' => '20.0'
        },
        'travel' => {
          'gross_cost' => '120.0',
          'net_cost' => '100',
          'vat' => '20.0'
        },
        'waiting' => {
          'gross_cost' => '120.0',
          'net_cost' => '100',
          'vat' => '20.0'
        },
      }
    end
    supporting_evidences do
      [
        {
          'id' =>  '650c33373ec7a3f8624fdc46',
          'file_name' =>  'Advocacy evidence _ Tom_TC.pdf',
          'file_path' =>  '#',
          'created_at' =>  '2023-09-18T14:12:50.825Z',
          'updated_at' =>  '2023-09-18T14:12:50.825Z',
          'document_type' => 'application/pdf',
          'documentable_id' => '650c33373ec7a3f8624fdc46',
          'documentable_type' => 'supporting_evidence',
          'file_size' => 123,
          'file_type' => 'application/pdf',
        },
        {
          'id' =>  '650c3337e9fe6be2870684e3',
          'file_name' =>  'Other evidence _ Tom_TC.pdf',
          'file_path' =>  '#',
          'created_at' =>  '2023-09-18T14:12:50.825Z',
          'updated_at' =>  '2023-09-18T14:12:50.825Z',
          'document_type' => 'application/pdf',
          'documentable_id' => '650c33373ec7a3f8624fdc46',
          'documentable_type' => 'supporting_evidence',
          'file_size' => 123,
          'file_type' => 'application/pdf',
        }
      ]
    end
    letters_and_calls do
      [
        {
          'type' => 'letters',
          'count' => 12,
          'uplift' => 95,
          'pricing' => 3.56
        },
        {
          'type' => 'calls',
          'count' => 4,
          'uplift' => 20,
          'pricing' => 3.56
        },
      ]
    end
    disbursements do
      [
        {
          'id' => '1c0f36fd-fd39-498a-823b-0a3837454563',
          'details' => 'Details',
          'pricing' => 1.0,
          'vat_rate' => 0.2,
          'apply_vat' => 'false',
          'other_type' => 'accountants',
          'vat_amount' => 0.0,
          'prior_authority' => 'yes',
          'disbursement_date' => '2022-12-12',
          'disbursement_type' => 'other',
          'total_cost_without_vat' => 100.0,
          'miles' => nil,
          'position' => 1,
        }
      ]
    end
    work_items do
      [
        {
          'id' => 'cf5e303e-98dd-4b0f-97ea-3560c4c5f137',
          'uplift' => 95,
          'pricing' => 24.0,
          'work_type' => 'waiting',
          'fee_earner' => 'aaa',
          'time_spent' => 161,
          'completed_on' => '2022-12-12',
          'position' => 1
        }
      ]
    end
    defendants do
      [
        {
          'id' =>  '40fb1f88-6dea-4b03-9087-590436b62dd8',
          'maat' =>  'AB12123',
          'main' =>  true,
          'position' =>  1,
          'first_name' =>  'Tracy',
          'last_name' => 'Linklater'
        }
      ]
    end
    vat_rate { 0.2 }
    vat_registered { 'no' }
    firm_office do
      {
        'name' => 'Blundon Solicitor Firm',
        'town' => 'Stoke Newington',
        'postcode' => 'NE10 4AB',
        'previous_id' => nil,
        'account_number' => '121234',
        'address_line_1' => 'Suite 3',
        'address_line_2' => '5 Princess Road',
        'vat_registered' => vat_registered
      }
    end
    solicitor do
      {
        'first_name' => 'Barry',
        'last_name' => 'Scott',
        'reference_number' => '2P314B',
        'contact_first_name' => 'Joe',
        'contact_last_name' => 'Bloggs',
        'contact_email' => 'joe@bloggs.com',
        'previous_id' => nil
      }
    end
    adjusted_total { nil }
    adjusted_total_inc_vat { nil }
    arrest_warrant_date { nil }
    conclusion { nil }
    cracked_trial_date { nil }
    created_at { '2023-12-12 15:15:15.000' }
    defence_statement { 12 }
    disability { nil }
    ethnic_group { nil }
    first_hearing_date { '2012-12-12' }
    gender { nil }
    id { '123123123-123123123-123123123' }
    main_offence { 'assault' }
    main_offence_date { '2023-12-12' }
    number_of_hearing { 12 }
    number_of_witnesses { 12 }
    office_code { 'AB11AB' }
    other_info { nil }
    plea { 'guilty' }
    plea_category { 'guilty_pleas' }
    prosecution_evidence { 0 }
    reason_for_claim_other_details { nil }
    remitted_to_magistrate_date { nil }
    representation_order_withdrawn_date { nil }
    signatory_name { 'Joe Bloggs' }
    submitted_total { nil }
    submitted_total_inc_vat { nil }
    time_spent { nil }
    wasted_costs { 'yes' }
    work_after_date { nil }
    work_before_date { nil }
    status { 'submitted' }
    assessment_comment { nil }
    updated_at { 1.day.ago }
    include_youth_court_fee { false }
    include_youth_court_fee_original { nil }

    trait :with_adjustments do
      disbursements do
        [
          {
            'id' => '1234-adj',
            'details' => 'Details',
            'pricing' => 1.0,
            'vat_rate' => 0.2,
            'apply_vat' => 'false',
            'other_type' => 'accountants',
            'vat_amount' => 0.0,
            'vat_amount_original' => 1.0,
            'total_cost' => 140.0,
            'total_cost_original' => 130.0,
            'total_cost_without_vat' => 130.0,
            'total_cost_without_vat_original' => 100.0,
            'prior_authority' => 'yes',
            'disbursement_date' => '2022-12-23',
            'disbursement_type' => 'other',
            'adjustment_comment' => 'adjusted up',
            'miles' => nil,
            'position' => 1,
          },
          {
            'id' => '5678',
            'details' => 'Details',
            'pricing' => 1.0,
            'vat_rate' => 0.2,
            'apply_vat' => 'false',
            'other_type' => 'accountants',
            'vat_amount' => 0.0,
            'total_cost' => 140.0,
            'total_cost_without_vat' => 130.0,
            'prior_authority' => 'yes',
            'disbursement_date' => '2022-12-23',
            'disbursement_type' => 'other',
            'miles' => nil,
            'position' => 1,
          }
        ]
      end
      letters_and_calls do
        [
          {
            'type' => 'letters',
            'count' => 12,
            'count_original' => 5,
            'uplift' => 95,
            'uplift_original' => 50,
            'pricing' => 3.56,
            'adjustment_comment' => 'adj'
          },
          {
            'type' => 'calls',
            'count' => 4,
            'count_original' => 5,
            'uplift' => 20,
            'uplift_original' => 50,
            'pricing' => 3.56,
            'adjustment_comment' => 'adj'
          },
        ]
      end
      work_items do
        [
          {
            'id' => '1234-adj',
            'uplift' => 95,
            'uplift_original' => 50,
            'pricing' => 24.0,
            'pricing_original' => 44.0,
            'work_type' => 'waiting',
            'work_type_original' => 'attendance_without_counsel',
            'fee_earner' => 'aaa',
            'time_spent' => 161,
            'time_spent_original' => 181,
            'completed_on' => '2022-12-12',
            'adjustment_comment' => 'some comment',
            'position' => 1,
          }
        ]
      end
      include_youth_court_fee { false }
      include_youth_court_fee_original { true }
      youth_court_fee_adjustment_comment { 'removed the fee' }
    end

    trait :increase_adjustment do
      disbursements do
        [
          {
            'id' => '1c0f36fd-fd39-498a-823b-0a3837454563',
            'details' => 'Details',
            'pricing' => 1.0,
            'vat_rate' => 0.2,
            'apply_vat' => 'false',
            'other_type' => 'accountants',
            'vat_amount_original' => 1.0,
            'vat_amount' => 0.0,
            'total_cost_original' => 130.0,
            'total_cost' => 140.0,
            'total_cost_without_vat_original' => 100.0,
            'total_cost_without_vat' => 130.0,
            'prior_authority' => 'yes',
            'disbursement_date' => '2022-12-23',
            'disbursement_type' => 'other',
            'adjustment_comment' => 'adjusted up'
          }
        ]
      end
    end

    trait :decrease_adjustment do
      disbursements do
        [
          {
            'id' => '1c0f36fd-fd39-498a-823b-0a3837454563',
            'details' => 'Details',
            'pricing' => 1.0,
            'vat_rate' => 0.2,
            'apply_vat' => 'false',
            'other_type' => 'accountants',
            'vat_amount_original' => 1.0,
            'vat_amount' => 0.0,
            'total_cost_original' => 130.0,
            'total_cost' => 110.0,
            'total_cost_without_vat_original' => 100.0,
            'total_cost_without_vat' => 80.0,
            'prior_authority' => 'yes',
            'disbursement_date' => '2022-12-12',
            'disbursement_type' => 'other'
          }
        ]
      end
    end

    trait :legacy_translations do
      laa_reference { 'LAA-FHaMVK' }
      ufn { '123456/001' }
      cntp_order { nil }
      cntp_date { nil }
      submitter do
        {
          'email' => 'provider@example.com',
          'description' => nil
        }
      end
      send_by_post { nil }
      letters_and_calls do
        [
          {
            'type' => {
              'en' => 'Letters',
              'value' => 'letters'
            },
              'count' => 12,
              'uplift' => 95,
              'pricing' => 3.56
          },
          {
            'type' => {
              'en' => 'Calls',
              'value' => 'calls'
            },
              'count' => 4,
              'uplift' => 20,
              'pricing' => 3.56
          },
        ]
      end
      disbursements do
        [
          {
            'id' => '1c0f36fd-fd39-498a-823b-0a3837454563',
            'details' => 'Details',
            'pricing' => 1.0,
            'vat_rate' => 0.2,
            'apply_vat' => 'false',
            'other_type' => 'accountants',
            'vat_amount' => 0.0,
            'prior_authority' => 'yes',
            'disbursement_date' => '2022-12-12',
            'disbursement_type' => {
              'en' => 'Other',
              'value' => 'other'
            },
            'total_cost_without_vat' => 100.0
          }
        ]
      end
      work_items do
        [
          {
            'id' => 'cf5e303e-98dd-4b0f-97ea-3560c4c5f137',
            'uplift' => 95,
            'pricing' => 24.0,
            'work_type' => {
              'en' => 'Waiting',
              'value' => 'waiting'
            },
            'fee_earner' => 'aaa',
            'time_spent' => 161,
            'completed_on' => '2022-12-12'
          }
        ]
      end
      defendants do
        [
          {
            'id' =>  '40fb1f88-6dea-4b03-9087-590436b62dd8',
            'maat' =>  'AB12123',
            'main' =>  true,
            'position' =>  1,
            'first_name' =>  'Tracy',
            'last_name' => 'Linklater'
          }
        ]
      end
      supporting_evidences do
        [
          {
            'id' =>  '650c33373ec7a3f8624fdc46',
            'file_name' =>  'Advocacy evidence _ Tom_TC.pdf',
            'file_path' =>  '#',
            'created_at' =>  '2023-09-18T14:12:50.825Z',
            'updated_at' =>  '2023-09-18T14:12:50.825Z',
            'document_type' => 'application/pdf',
            'documentable_id' => '650c33373ec7a3f8624fdc46',
            'documentable_type' => 'supporting_evidence',
            'file_size' => 123,
            'file_type' => 'application/pdf',
          },
          {
            'id' =>  '650c3337e9fe6be2870684e3',
            'file_name' =>  'Other evidence _ Tom_TC.pdf',
            'file_path' =>  '#',
            'created_at' =>  '2023-09-18T14:12:50.825Z',
            'updated_at' =>  '2023-09-18T14:12:50.825Z',
            'document_type' => 'application/pdf',
            'documentable_id' => '650c33373ec7a3f8624fdc46',
            'documentable_type' => 'supporting_evidence',
            'file_size' => 123,
            'file_type' => 'application/pdf',
          }
        ]
      end
      vat_rate { 0.2 }
      firm_office do
        {
          'name' => 'Blundon Solicitor Firm',
          'town' => 'Stoke Newington',
          'postcode' => 'NE10 4AB',
          'previous_id' => nil,
          'account_number' => '121234',
          'address_line_1' => 'Suite 3',
          'address_line_2' => '5 Princess Road',
          'vat_registered' => vat_registered
        }
      end
      solicitor do
        {
          'first_name' => 'Barry',
          'last_name' => 'Scott',
          'reference_number' => '2P314B',
          'contact_first_name' => 'Joe',
          'contact_last_name' => 'Bloggs',
          'contact_email' => 'joe@bloggs.com',
          'previous_id' => nil
        }
      end
      assigned_counsel { 'no' }
      unassigned_counsel { 'yes' }
      agent_instructed { 'no' }
      remitted_to_magistrate { 'no' }
      reasons_for_claim do
        [
          {
            'value' => 'counsel_or_agent_assigned',
            'en' => 'Counsel or agent assigned'
          }
        ]
      end
      supplemental_claim { 'no' }
      preparation_time { 'no' }
      work_before { 'no' }
      work_after { 'no' }
      work_completed_date { '2024-01-01' }
      has_disbursements { 'no' }
      is_other_info { 'no' }
      youth_court { 'no' }
      hearing_outcome do
        {
          'value' => 'CP05',
          'en' => 'CP01 - Arrest warrant issued/adjourned indefinitely'
        }
      end
      claim_type do
        {
          'en' => "Non-standard magistrates' court payment",
          'value' => 'non_standard_magistrate'
        }
      end
      rep_order_date { '2024-10-9' }
      matter_type do
        {
          'value' => '10',
          'en' => '1 - Offences against the person'
        }
      end
      concluded { 'no' }
      answer_equality do
        {
          'value' => 'no',
          'en' => 'No, skip the equality questions'
        }
      end
      stage_reached { 'prog' }
      work_item_pricing do
        {
          'waiting' => 45.5,
          'preparation' => 23.2,
          'attendance_without_counsel' => 10.17,
        }
      end
    end
  end
end
