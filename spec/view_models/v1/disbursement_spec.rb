require 'rails_helper'

RSpec.describe V1::Disbursement do
  describe 'adjustment' do
    it 'returns pending' do
      disbursement = described_class.new({})
      expect(disbursement.adjustments).to eq(0)
    end
  end

  describe 'requested' do
    it 'returns pending' do
      disbursement = described_class.new({})
      expect(CostCalculator).to receive(:cost).with(:disbursement, disbursement).and_return(10.0)
      expect(disbursement.requested).to eq(10.0)
    end
  end

  describe 'table_fields' do
    before do
      allow(CostCalculator).to receive(:cost).and_return(10.0)
    end

    it 'returns the fields for the table display' do
      disbursement = described_class.new('disbursement_type' => { 'en' => 'Car' })
      expect(disbursement.table_fields).to eq(['Car', '£10.00', '£'])
    end
  end
end
