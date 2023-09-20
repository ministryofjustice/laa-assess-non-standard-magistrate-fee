require 'rails_helper'

RSpec.describe V1::LetterAndCall do
  describe '#provider_requested_amount' do
    let(:letter_and_call) { described_class.new(type: 'letter', count: 1, uplift: 5, pricing: 10.0) }

    it 'calculates the correct provider requested amount' do
      expect(letter_and_call.provider_requested_amount).to eq(10.5)
    end
  end

  describe '#uplift_amount' do
    context 'when uplift has a value' do
      let(:letter_and_call) { described_class.new(uplift: 5) }

      it 'returns the uplift amount as a percentage' do
        expect(letter_and_call.uplift_amount).to eq('5%')
      end
    end

    context 'when uplift is nil' do
      let(:letter_and_call) { described_class.new(uplift: nil) }

      it 'returns 0% as the uplift amount' do
        expect(letter_and_call.uplift_amount).to eq('0%')
      end
    end
  end

  describe '#table_fields' do
    before do
      allow(CostCalculator).to receive(:cost).and_return(10.0)
    end

    it 'returns the fields for the table display' do
      letter_and_call = described_class.new('type' => { 'en' => 'Letters', 'value' => 'letters' }, 'count' => 12,
                                            'uplift' => 0, 'pricing' => 3.56)
      expect(letter_and_call.table_fields).to eq(['Letters', '12', '0%', '£10.00', '#pending#', '#pending#'])
    end
  end
end
