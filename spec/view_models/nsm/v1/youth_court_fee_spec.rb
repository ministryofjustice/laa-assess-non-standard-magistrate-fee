require 'rails_helper'

RSpec.describe Nsm::V1::YouthCourtFee do
  subject(:additional_fee) { described_class.new(params.merge(type: :youth_court_fee, submission: build(:claim))) }

  describe '#table_fields' do
    let(:params) do
      {
        'type' => 'youth_court_fee',
        'include_youth_court_fee' => true,
        'claimed_total_exc_vat' => 598.59,
        'assessed_total_inc_vat' => 0
      }
    end

    it 'returns the fields for the table display' do
      expect(additional_fee.table_fields).to eq(
        [
          I18n.t("nsm.additional_fees.index.#{params['type']}"),
          { numeric: true, text: '£598.59' }, ''
        ]
      )
    end

    context 'when the fee has been assessed' do
      let(:params) do
        {
          'type' => 'youth_court_fee',
          'include_youth_court_fee' => true,
          'claimed_total_exc_vat' => 598.59,
          'assessed_total_exc_vat' => 598.59,
          'adjustment_comment' => 'assessed'
        }
      end

      it 'returns the fields for the table display' do
        expect(additional_fee.table_fields).to eq(
          [
            I18n.t("nsm.additional_fees.index.#{params['type']}"),
            { numeric: true, text: '£598.59' }, '',
          ]
        )
      end
    end
  end

  describe '#provider_fields' do
    let(:params) do
      {
        'type' => 'youth_court_fee',
        'claimed_total_exc_vat' => 598.59
      }
    end

    it 'returns the fields for the table display' do
      expect(additional_fee.provider_fields).to eq(
        {
          '.additional_fee' => 'Youth court fee',
          '.net_cost_claimed' => '£598.59'
        }
      )
    end
  end

  describe '#caseworker_fields' do
    let(:params) do
      {
        'type' => 'youth_court_fee',
        'claimed_total_exc_vat' => 598.59,
        'assessed_total_exc_vat' => 0.00,
        'youth_court_fee_adjustment_comment' => 'assessed'
      }
    end

    it 'returns the fields for the table display' do
      expect(additional_fee.caseworker_fields).to eq(
        { '.net_cost_allowed' => '£0.00',
          '.reason_for_adjustments' => 'assessed' }
      )
    end
  end

  describe '#backlink_path' do
    context 'when no change has been made' do
      let(:claim) { build(:claim) }
      let(:params) do
        {
          'type' => 'youth_court_fee',
        }
      end

      it 'returns the expected path' do
        expected_path = Rails.application.routes.url_helpers.nsm_claim_additional_fees_path(claim)
        expect(additional_fee.backlink_path(claim)).to eq(expected_path)
      end
    end

    context 'when a change has been made' do
      let(:claim) { build(:claim) }
      let(:params) do
        {
          'type' => 'youth_court_fee',
        }
      end

      it 'returns the expected path' do
        allow(subject).to receive(:any_adjustments?).and_return(true)
        expected_path = Rails.application.routes.url_helpers.adjusted_nsm_claim_additional_fees_path(claim)
        expect(additional_fee.backlink_path(claim)).to eq(expected_path)
      end
    end
  end
end
