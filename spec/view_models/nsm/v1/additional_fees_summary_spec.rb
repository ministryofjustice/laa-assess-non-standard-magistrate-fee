require 'rails_helper'

module Nsm
  module V1
    class DummyAdditionalFee < AdditionalFee
      attr_accessor :some_attribute

      def type
        :dummy_additional_fee
      end
    end
  end
end

RSpec.describe Nsm::V1::AdditionalFeesSummary do
  let(:claim) { build(:claim) }

  describe 'rows' do
    it 'instantiates the rows correctly' do
      summary = described_class.new('submission' => claim)
      expect(summary.rows.count).to eq(1)
      expect(summary.rows.first.type).to eq(:youth_court_fee)
    end
  end

  describe 'rows with more than one fee type' do
    let(:dummy_fee) { claim.additional_fees.merge(dummy_additional_fee: { claimed_total_exc_vat: 598.59 }) }

    it 'instantiates the rows correctly' do
      allow(claim).to receive(:additional_fees).and_return(dummy_fee)
      summary = described_class.new('submission' => claim)
      expect(summary.rows.count).to eq(2)
      expect(summary.rows[1].type).to eq(:dummy_additional_fee)
    end
  end
end
