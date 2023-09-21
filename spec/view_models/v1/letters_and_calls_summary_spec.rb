require 'rails_helper'

RSpec.describe V1::LettersAndCallsSummary, type: :model do
  before do
    allow(CostCalculator).to receive(:cost).and_return(10.50)
  end

  let(:letters_and_calls) do
    [{ 'type' => { 'en' => 'Letters', 'value' => 'letters' }, 'count' => 12, 'uplift' => 0, 'pricing' => 3.56 }]
  end
  let(:letters_and_calls_summary) { described_class.new(letters_and_calls:) }

  describe '#table_fields' do
    it 'returns an array of table fields' do
      expect(letters_and_calls_summary.table_fields).to eq([['Letters', '£10.50']])
    end
  end

  describe '#summed_fields' do
    it 'returns an array of summed fields' do
      expect(letters_and_calls_summary.summed_fields).to eq(['£10.50'])
    end
  end

  describe '#summary_row' do
    it 'returns an array of summary row fields' do
      expect(letters_and_calls_summary.summary_row).to eq(['12', '-', '£10.50', '-', '#pending#'])
    end
  end
end
