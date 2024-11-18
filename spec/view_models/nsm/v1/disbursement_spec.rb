require 'rails_helper'

RSpec.describe Nsm::V1::Disbursement do
  let(:disbursement) { described_class.new(args) }
  let(:args) { {} }

  describe '#original_total_cost_without_vat' do
    context 'when original value is present' do
      let(:args) { { 'total_cost_without_vat_original' => 100 } }

      it 'returns the explicit original value' do
        expect(disbursement.original_total_cost_without_vat).to eq(100)
      end
    end

    context 'when original value is not present' do
      let(:args) { { 'total_cost_without_vat' => 100 } }

      it 'returns the current value' do
        expect(disbursement.original_total_cost_without_vat).to eq(100)
      end
    end
  end

  describe '#provider_requested_total_cost' do
    let(:args) do
      { 'total_cost_without_vat_original' => 240,
        'total_cost_without_vat' => 100,
        'disbursement_type' => 'other',
        'apply_vat' => 'true',
        :submission => build(:claim) }
    end

    it 'calculates the cost' do
      expect(disbursement.provider_requested_total_cost).to eq(288.0)
    end
  end

  describe '#caseworker_total_cost' do
    context 'when amount without vat is zero' do
      let(:args) do
        { 'total_cost_without_vat' => 0, 'disbursement_type' => 'other', 'apply_vat' => 'true', :submission => build(:claim) }
      end

      it 'returns calculated cost' do
        expect(disbursement.caseworker_total_cost).to eq(0)
      end
    end

    context 'when amount without vat is not zero' do
      let(:args) do
        { 'total_cost_without_vat' => 120, 'disbursement_type' => 'other', 'apply_vat' => 'true', :submission => build(:claim) }
      end

      it 'returns the calculated cost' do
        expect(disbursement.caseworker_total_cost).to eq(144)
      end
    end
  end

  describe '#disbursement_fields' do
    let(:args) do
      {
        'total_cost_without_vat' => 83.3,
        'disbursement_date' => Date.new(2022, 1, 1),
        'other_type' => other_type,
        'disbursement_type' => disbursement_type,
        'details' => 'details',
        'prior_authority' => prior_authority,
        'apply_vat' => apply_vat,
        'miles' => miles,
        :submission => build(:claim),
      }
    end

    let(:prior_authority) { 'yes' }
    let(:miles) { nil }
    let(:apply_vat) { 'true' }
    let(:other_type) { 'accountants' }
    let(:disbursement_type) { 'other' }

    it 'returns a hash with the correct fields if no miles' do
      expected_fields = {
        date: '1 January 2022',
        type: 'Accountants',
        details: 'Details',
        prior_authority: 'Yes',
        vat: '20%',
        total: '£99.96'
      }

      expect(disbursement.disbursement_fields).to eq(expected_fields)
    end

    context 'when miles is set' do
      let(:miles) { 10 }
      let(:disbursement_type) { 'car' }

      it 'returns a hash with the correct fields if miles present' do
        expected_fields = {
          date: '1 January 2022',
          type: 'Accountants',
          details: 'Details',
          prior_authority: 'Yes',
          vat: '20%',
          miles: '10.0',
          total: '£5.40'
        }

        expect(disbursement.disbursement_fields).to eq(expected_fields)
      end
    end

    context 'when apply vat is false' do
      let(:apply_vat) { 'false' }

      it 'returns a hash with the correct fields if apply vat is false' do
        expected_fields = {
          date: '1 January 2022',
          type: 'Accountants',
          details: 'Details',
          prior_authority: 'Yes',
          vat: '20%',
          total: '£83.30'
        }

        expect(disbursement.disbursement_fields).to eq(expected_fields)
      end
    end

    context 'when prior_authority is nil' do
      let(:prior_authority) { nil }

      it 'returns a hash excluding prior_authority' do
        expected_fields = {
          date: '1 January 2022',
          type: 'Accountants',
          details: 'Details',
          vat: '20%',
          total: '£99.96'
        }

        expect(disbursement.disbursement_fields).to eq(expected_fields)
      end
    end

    context 'when other type is a custom value' do
      let(:other_type) { 'Some fun custom thing' }

      it 'shows the custom value directly' do
        expect(disbursement.disbursement_fields[:type]).to eq(other_type)
      end
    end

    context 'when other type not set' do
      let(:other_type) { nil }
      let(:disbursement_type) { 'car' }
      let(:miles) { 10 }

      it 'shows the main type name' do
        expect(disbursement.disbursement_fields[:type]).to eq('Car mileage')
      end
    end

    context 'when a change has been made' do
      let(:claim) { build(:claim) }
      let(:args) do
        { 'adjustment_comment' => 'test' }
      end

      it 'returns the expected path' do
        expected_path = Rails.application.routes.url_helpers.adjusted_nsm_claim_disbursements_path(claim,
                                                                                                   anchor: disbursement.id)
        expect(disbursement.backlink_path(claim)).to eq(expected_path)
      end
    end

    context 'when no change has been made' do
      let(:claim) { build(:claim) }

      it 'returns the expected path' do
        expected_path = Rails.application.routes.url_helpers.nsm_claim_disbursements_path(claim,
                                                                                          anchor: disbursement.id)
        expect(disbursement.backlink_path(claim)).to eq(expected_path)
      end
    end
  end

  describe 'table fields' do
    let(:adjustment_comment) { 'something' }
    let(:args) do
      {
        'total_cost_without_vat_original' => 74,
        'total_cost_without_vat' => 83,
        'disbursement_date' => Date.new(2022, 1, 1),
        'apply_vat_original' => 'true',
        'apply_vat' => 'false',
        'adjustment_comment' => adjustment_comment,
        :submission => build(:claim),
        'disbursement_type' => 'other',

      }
    end

    describe '#date' do
      it { expect(disbursement.date).to eq('1 Jan 2022') }
    end

    describe '#reason' do
      it { expect(disbursement.reason).to eq('something') }
    end

    describe '#claimed_net' do
      it { expect(disbursement.claimed_net).to eq('£74.00') }
    end

    describe '#claimed_vat' do
      it { expect(disbursement.claimed_vat).to eq('£14.80') }
    end

    describe '#claimed_gross' do
      it { expect(disbursement.claimed_gross).to eq('£88.80') }
    end

    describe '#allowed_net' do
      it { expect(disbursement.allowed_net).to eq('£83.00') }
    end

    describe '#allowed_vat' do
      it { expect(disbursement.allowed_vat).to eq('£0.00') }
    end

    describe '#allowed_gross' do
      it { expect(disbursement.allowed_gross).to eq('£83.00') }
    end
  end

  describe '#reduced?' do
    subject { disbursement.reduced? }

    context 'with a reduced total cost' do
      let(:args) do
        {
          'total_cost_without_vat_original' => 250,
          'total_cost_without_vat' => 240,
          :submission => build(:claim),
          :disbursement_type => 'other',
        }
      end

      it { is_expected.to be true }
    end

    context 'with an increased total cost' do
      let(:args) do
        {
          'total_cost_without_vat_original' => 250,
          'apply_vat_original' => 'false',
          'total_cost_without_vat' => 250,
          'apply_vat' => true,
          :submission => build(:claim),
          :disbursement_type => 'other',
        }
      end

      it { is_expected.to be false }
    end

    context 'with an unchanged total cost' do
      let(:args) do
        {
          'total_cost_without_vat' => 250,
          :submission => build(:claim),
          :disbursement_type => 'other',
        }
      end

      it { is_expected.to be false }
    end
  end

  describe '#increased?' do
    subject { disbursement.increased? }

    context 'with a reduced total cost' do
      let(:args) do
        {
          'total_cost_without_vat_original' => 250,
          'total_cost_without_vat' => 240,
          :submission => build(:claim),
          :disbursement_type => 'other',
        }
      end

      it { is_expected.to be false }
    end

    context 'with an increased total cost' do
      let(:args) do
        {
          'total_cost_without_vat_original' => 250,
          'apply_vat_original' => 'false',
          'total_cost_without_vat' => 250,
          'apply_vat' => 'true',
          :submission => build(:claim),
          :disbursement_type => 'other',
        }
      end

      it { is_expected.to be true }
    end

    context 'with an unchanged total cost' do
      let(:args) do
        {
          'total_cost_without_vat' => 250,
          :submission => build(:claim),
          :disbursement_type => 'other',
        }
      end

      it { is_expected.to be false }
    end
  end
end
