require 'rails_helper'

RSpec.describe Nsm::V1::AdditionalFeesSummary do
  let(:claim) { build(:claim) }

  describe 'rows' do
    it 'instantiates the rows correctly' do
      summary = described_class.new('submission' => claim)
      expect(summary.rows.count).to eq(1)
      expect(summary.rows.first.type).to eq(:youth_court_fee)
    end
  end
end
