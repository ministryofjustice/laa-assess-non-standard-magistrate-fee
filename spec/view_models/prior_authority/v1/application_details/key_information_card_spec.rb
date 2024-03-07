require 'rails_helper'

RSpec.describe PriorAuthority::V1::ApplicationDetails::KeyInformationCard do
  subject(:key_information) { described_class.new(application_summary) }

  let(:klass) { PriorAuthority::V1::KeyInformation }

  describe '#primary_quote_postcode' do
    let(:application_summary) { klass.new(args) }

    let(:args) do
      {
        quotes: [
          {
            'primary' => true,
            'postcode' => 'E15 3JQ',
          },
        ],
      }
    end

    it 'returns the postcode from the quote marked as primary true' do
      expect(key_information.primary_quote_postcode).to eq('E15 3JQ')
    end
  end
end
