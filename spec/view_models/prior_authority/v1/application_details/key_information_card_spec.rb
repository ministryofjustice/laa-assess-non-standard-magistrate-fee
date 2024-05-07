require 'rails_helper'

RSpec.describe PriorAuthority::V1::ApplicationDetails::KeyInformationCard do
  subject(:key_information) { described_class.new(application_summary) }

  let(:klass) { PriorAuthority::V1::KeyInformation }
  let(:application_summary) { klass.new(args) }

  describe '#primary_quote_location' do
    let(:args) do
      {
        quotes: [
          {
            'primary' => true,
            'town' => 'Royston Vasey',
            'postcode' => 'E15',
          },
        ],
      }
    end

    it 'returns the town and postcode from the quote marked as primary true' do
      expect(key_information.primary_quote_location).to eq('Royston Vasey, E15')
    end
  end

  describe '#ufn' do
    let(:args) do
      {
        prison_law: false,
        ufn: '121212/001'
      }
    end

    it 'returns nil when not prison law' do
      expect(key_information.ufn).to be_nil
    end
  end

  context 'when it is a prison law case' do
    let(:args) do
      {
        prison_law: true,
        ufn: '121212/001'
      }
    end

    describe '#main_offence' do
      it 'returns nil' do
        expect(key_information.main_offence).to be_nil
      end
    end

    describe '#ufn' do
      it 'returns the ufn' do
        expect(key_information.ufn).to eq '121212/001'
      end
    end
  end
end
