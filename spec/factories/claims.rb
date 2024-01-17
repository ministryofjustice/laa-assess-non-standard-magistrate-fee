FactoryBot.define do
  factory :claim do
    risk { 'low' }
    received_on { Date.yesterday }
    current_version { 1 }
    state { 'submitted' }
    json_schema_version { 1 }
    data do
      {
        'laa_reference' => 'LAA-FHaMVK',
        'ufn' => '123456/001',
        'cntp_order' => nil,
        'cntp_date' => nil,
        'submitter' => submitter,
        'send_by_post' => send_by_post,
        'letters_and_calls' => letters_and_calls,
        'disbursements' => disbursements,
        'work_items' => work_items,
        'defendants' => defendants,
        'supporting_evidences' => supporting_evidences,
        'vat_rate' => vat_rate,
        'firm_office' => firm_office,
        'assigned_counsel' => 'no',
        'unassigned_counsel' => 'yes',
        'agent_instructed' => 'no',
        'remitted_to_magistrate' => 'no',
        'reasons_for_claim' => [
          {
            'value' => 'councel_or_agent_assigned',
            'en' => 'Councel or agent assigned'
          }
        ],
        'supplemental_claim' => 'no',
        'preparation_time' => 'no',
        'work_before' => 'no',
        'work_after' => 'no',
        'has_disbursements' => 'no',
        'is_other_info' => 'no',
        'in_area' => 'yes',
        'youth_court' => 'no',
        'hearing_outcome' => {
          'value' => 'CP05',
          'en' => 'CP01 - Arrest warrant issued/adjourned indefinitely'
        },
        'matter_type' => {
          'value' => '10',
          'en' => '1 - Offences against the person'
        },
        'concluded' => 'no',
        'solicitor' => {
          'full_name' => 'Barry Scott',
          'reference_number' => '2P314B',
          'contact_full_name' => nil,
          'contact_email' => nil,
          'previous_id' => nil
        },
        'answer_equality' => {
          'value' => 'no',
          'en' => 'No, skip the equality questions'
        },
      }
    end

    transient do
      submitter do
        {
          'email' => 'provider@example.com',
          'description' => nil
        }
      end
      send_by_post { false }
      supporting_evidences do
        [
          {
            'id' =>  '650c33373ec7a3f8624fdc46',
            'file_name' =>  'Advocacy evidence _ Tom_TC.pdf',
            'content_type' =>  'application/pdf',
            'file_path' =>  '#',
            'created_at' =>  '2023-09-18T14:12:50.825Z',
            'updated_at' =>  '2023-09-18T14:12:50.825Z'
          },
          {
            'id' =>  '650c3337e9fe6be2870684e3',
            'file_name' =>  'Prior Authority_ Psychiatric report_ Tom_TC.png',
            'content_type' =>  'application/pdf',
            'file_path' =>  '#',
            'created_at' =>  '2023-09-18T14:12:50.825Z',
            'updated_at' =>  '2023-09-18T14:12:50.825Z'
          }
        ]
      end
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
            'other_type' => {
              'en' => 'Apples',
              'value' => 'Apples'
            },
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
            'full_name' =>  'Tracy Linklater'
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
    end

    trait :with_assignment do
      after(:build) do |claim|
        claim.assignments << build(:assignment, claim:)
      end
    end
  end
end
