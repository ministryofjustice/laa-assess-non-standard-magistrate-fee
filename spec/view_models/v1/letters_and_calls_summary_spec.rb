require 'rails_helper'

RSpec.describe V1::LettersAndCallsSummary, type: :model do
  before do
    allow(CostCalculator).to receive(:cost).and_return(10.50)
  end

  let(:letters_and_calls) do
    [{ 'type' => { 'en' => 'Letters', 'value' => 'letters' }, 'count' => 12, 'uplift' => 0, 'pricing' => 3.56 }]
  end
  let(:claim) { Claim.new }
  let(:letters_and_calls_summary) { described_class.new(letters_and_calls:, claim:) }

  describe '#summary_row' do
    it 'returns an array of summary row fields' do
      expect(letters_and_calls_summary.summary_row).to eq(['12', '-', '£10.50', '-', '£10.50'])
    end
  end
end
