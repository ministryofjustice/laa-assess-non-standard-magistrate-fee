require 'rails_helper'

RSpec.describe Nsm::V1::ClaimSummary do
  describe 'main_defendant_name' do
    it 'returns the name attibute from the main defendant' do
      defendants = [
        { 'main' => false, 'first_name' => 'John', 'last_name' => 'Doe' },
        { 'main' => true, 'first_name' => 'John', 'last_name' => 'Roe' },
      ]
      summary = described_class.new('defendants' => defendants)
      expect(summary.main_defendant_name).to eq('John Roe')
    end

    context 'when no main defendant record - shouold not be possible' do
      it 'returns an empty string' do
        defendants = [
          { 'main' => false, 'first_name' => 'John', 'last_name' => 'Doe' },
        ]
        summary = described_class.new('defendants' => defendants)
        expect(summary.main_defendant_name).to eq('')
      end
    end
  end

  describe 'send_by_post' do
    it 'returns the attribute send by post as bool' do
      send_by_post = true
      summary = described_class.new('send_by_post' => send_by_post)
      expect(summary.send_by_post).to be(true)
    end
  end
end
