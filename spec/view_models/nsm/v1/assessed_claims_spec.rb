require 'rails_helper'

RSpec.describe Nsm::V1::AssessedClaims, type: :view_model do
  subject(:assessed_claims) do
    described_class.new(laa_reference:, defendants:, firm_office:, submission:, state:)
  end

  let(:laa_reference) { '1234567890' }
  let(:defendants) do
    [{ 'first_name' => 'John', 'last_name' => 'Doe', 'main' => true },
     { 'main' => false, 'first_name' => 'jim', 'last_name' => 'bob' }]
  end
  let(:firm_office) { { 'name' => 'Acme Law Firm' } }
  let(:updated_at) { Time.zone.yesterday }
  let(:submission) { instance_double(Claim, id: 1, events: events, updated_at: updated_at) }
  let(:events) { double(where: double(order: [instance_double(Event, primary_user:)])) }
  let(:primary_user) { instance_double(User, display_name: 'Jim Bob') }
  let(:state) { 'granted' }

  describe '#main_defendant_name' do
    it 'returns the name of the main defendant' do
      summary = described_class.new('defendants' => defendants)
      expect(summary.main_defendant_name).to eq('John Doe')
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

  describe '#firm_name' do
    it 'returns the name of the firm office' do
      expect(assessed_claims.firm_name).to eq('Acme Law Firm')
    end
  end

  describe '#case_worker_name' do
    it 'returns user anme from the last Desision Event' do
      expect(assessed_claims.case_worker_name).to eq('Jim Bob')
    end

    context 'when no decision event' do
      let(:events) { double(where: double(order: [])) }

      it 'returns nil' do
        expect(assessed_claims.case_worker_name).to eq('')
      end
    end
  end
end
