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

  describe 'total' do
    context 'there is an adjusted total' do
      it 'returns the correct total' do
        summary = described_class.new('adjusted_total' => 100.20, 'submitted_total' => 50.00)
        expect(summary.total).to eq('£100.20')
      end
    end

    context 'there is no adjusted total' do
      it 'returns the correct total' do
        summary = described_class.new('submitted_total' => 70.20)
        expect(summary.total).to eq('£70.20')
      end
    end

    context 'no total' do
      it 'returns nil' do
        summary = described_class.new()
        expect(summary.total).to eq(nil)
      end
    end
  end
end
