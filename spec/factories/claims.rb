FactoryBot.define do
  factory :claim do
    id { SecureRandom.uuid }
    risk { 'low' }
    received_on { Date.yesterday }
    current_version { 1 }
    state { 'submitted' }

    json_schema_version { 1 }
    data do
      {
        'laa_reference' => 'LAA-FHaMVK',
        'send_by_post' => true,
        'letters_and_calls' => [
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
        ],
        'disbursements' => [
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
        ],
        'work_items' => [
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
        ],
        'supporting_evidences' => [
          {
              "id" =>  "650c33373ec7a3f8624fdc46",
              "file_name" =>  "Advocacy evidence _ Tom_TC.pdf",
              "content_type" =>  "application/pdf",
              "file_url" =>  "#",
              "created_at" =>  "2023-09-18T14:12:50.825Z",
              "updated_at" =>  "2023-09-18T14:12:50.825Z"
          },
          {
              "id" =>  "650c3337e9fe6be2870684e3",
              "file_name" =>  "Prior Authority_ Psychiatric report_ Tom_TC.png",
              "content_type" =>  "application/pdf",
              "file_url" =>  "#",
              "created_at" =>  "2023-09-18T14:12:50.825Z",
              "updated_at" =>  "2023-09-18T14:12:50.825Z"
          }
        ],
        "defendants" => [
          {
            "id" =>  "40fb1f88-6dea-4b03-9087-590436b62dd8",
            "maat" =>  "AB12123",
            "main" =>  true,
            "position" =>  1,
            "full_name" =>  "Tracy Linklater"
          }
        ],
      }
    end
  end
end
