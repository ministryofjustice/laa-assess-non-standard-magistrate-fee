require 'rails_helper'

RSpec.describe V1::YourClaims, type: :view_model do
  subject(:your_claims) do
    described_class.new(laa_reference:, defendants:, firm_office:, created_at:, id:, risk:)
  end

  let(:laa_reference) { '1234567890' }
  let(:defendants) { [{ 'full_name' => 'John Doe', 'main' => true }, 'main' => false, 'full_name' => 'jimbob'] }
  let(:firm_office) { { 'name' => 'Acme Law Firm' } }
  let(:created_at) { Time.zone.yesterday }
  let(:id) { 1 }
  let(:risk) { 'low' }

  describe '#main_defendant_name' do
    it 'returns the name of the main defendant' do
      summary = described_class.new('defendants' => defendants)
      expect(summary.main_defendant_name).to eq('John Doe')
    end

    context 'when no main defendant record - shouold not be possible' do
      it 'returns an empty string' do
        defendants = [
          { 'main' => false, 'full_name' => 'John Doe' },
        ]
        summary = described_class.new('defendants' => defendants)
        expect(summary.main_defendant_name).to eq('')
      end
    end
  end

  describe '#firm_name' do
    it 'returns the name of the firm office' do
      expect(your_claims.firm_name).to eq('Acme Law Firm')
    end
  end

  describe '#case_worker_name' do
    it 'returns the pending status' do
      expect(your_claims.case_worker_name).to eq('#Pending#')
    end
  end

  describe '#get_risk' do
    it 'returns the risk with sorted value' do
      expect(subject.get_risk('high')).to eq({ text: 'high', sort_value: 1 })
      expect(subject.get_risk('medium')).to eq({ text: 'medium', sort_value: 2 })
      expect(subject.get_risk('low')).to eq({ text: 'low', sort_value: 3 })
      expect(subject.get_risk('invalid')).to be_nil
    end
  end

  describe '#table_fields' do
    it 'returns an array of table fields' do
      expected_fields = [
        { laa_reference: '1234567890', claim_id: 1 },
        'Acme Law Firm',
        'John Doe',
        { text: I18n.l(Time.zone.yesterday, format: '%-d %b %Y'), sort_value: Time.zone.yesterday.to_fs(:db) },
        '#Pending#',
        { text: 'low', sort_value: 3 }
      ]
      expect(your_claims.table_fields).to eq(expected_fields)
    end
  end
end
