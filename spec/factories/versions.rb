FactoryBot.define do
  factory :version do
    claim
    version { 1 }
    json_schema_version { 1 }
    state { 'submitted' }
    data do
      {
        'letters_and_calls' => [
          {
              "type" => {
                  "en" => "Letters",
                  "value" => "letters"
              },
              "count" => 12,
              "uplift" => 95,
              "pricing" => 3.56
          },
        ]
      }
    end
  end
end
