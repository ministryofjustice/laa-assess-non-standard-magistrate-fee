require 'rails_helper'

RSpec.describe V1::ClaimSummary do
  describe 'main_defendant_name' do
    it 'returns the name attibute from the main defendant' do
      defendants = [
        { 'main' => false, 'full_name' => 'jimbob' },
        { 'main' => true, 'full_name' => 'bobjim' },
      ]
      summary = described_class.new('defendants' => defendants)
      expect(summary.main_defendant_name).to eq('bobjim')
    end

    context 'when no main defendant record - shouold not be possible' do
      it 'returns an empty string' do
        defendants = [
          { 'main' => false, 'full_name' => 'jimbob' },
        ]
        summary = described_class.new('defendants' => defendants)
        expect(summary.main_defendant_name).to eq('')
      end
    end
  end
end
