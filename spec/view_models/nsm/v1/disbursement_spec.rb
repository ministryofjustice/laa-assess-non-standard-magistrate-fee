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
    let(:args) { { 'total_cost_without_vat_original' => 240, 'vat_amount_original' => 60 } }

    it 'calculates the cost' do
      expect(disbursement.provider_requested_total_cost).to eq(300)
    end
  end

  describe '#caseworker_total_cost' do
    context 'when amount without vat is zero' do
      let(:args) { { 'total_cost_without_vat' => 0, 'vat_amount' => 60 } }

      it 'returns 0' do
        expect(disbursement.caseworker_total_cost).to eq(0)
      end
    end

    context 'when amount without vat is not zero' do
      let(:args) { { 'total_cost_without_vat' => 120, 'vat_amount' => 60 } }

      it 'returns the calculated cost' do
        expect(disbursement.caseworker_total_cost).to eq(180)
      end
    end
  end

  describe '#disbursement_fields' do
    let(:args) do
      {
        'total_cost_without_vat' => 83, 'vat_amount' => 17,
        'disbursement_date' => Date.new(2022, 1, 1),
        'other_type' => { 'value' => 'type', 'en' => 'Type' },
        'details' => 'details',
        'prior_authority' => 'prior_authority',
        'vat_rate' => 0.2,
        'apply_vat' => apply_vat,
        'miles' => miles
      }
    end
    let(:miles) { nil }
    let(:apply_vat) { 'true' }

    it 'returns a hash with the correct fields if no miles' do
      expected_fields = {
        date: '01 Jan 2022',
        type: 'Type',
        details: 'Details',
        prior_authority: 'Prior_authority',
        vat: '20%',
        total: '£100.00'
      }

      expect(disbursement.disbursement_fields).to eq(expected_fields)
    end

    context 'when miles is set' do
      let(:miles) { 10 }

      it 'returns a hash with the correct fields if miles present' do
        expected_fields = {
          date: '01 Jan 2022',
          type: 'Type',
          details: 'Details',
          prior_authority: 'Prior_authority',
          vat: '20%',
          miles: '10.0',
          total: '£100.00'
        }

        expect(disbursement.disbursement_fields).to eq(expected_fields)
      end
    end

    context 'when apply vat is false' do
      let(:apply_vat) { 'false' }

      it 'returns a hash with the correct fields if apply vat is false' do
        expected_fields = {
          date: '01 Jan 2022',
          type: 'Type',
          details: 'Details',
          prior_authority: 'Prior_authority',
          total: '£100.00'
        }

        expect(disbursement.disbursement_fields).to eq(expected_fields)
      end
    end
  end

  describe 'table_fields' do
    let(:adjustment_comment) { nil }
    let(:args) do
      {
        'adjustment_comment' => adjustment_comment,
        'other_type' => { 'value' => 'type', 'en' => 'Type' },
        'total_cost_without_vat_original' => 100,
        'vat_amount_original' => 0,
        'total_cost_without_vat' => 0,
        'vat_amount' => 0,
      }
    end

    it 'returns the fields for the table display if no adjustments' do
      expect(disbursement.table_fields).to eq(
        [
          "Type",
          {:numeric=>true, :text=>"£100.00"},
          {:numeric=>true, :text=>"£0.00"},
          {:numeric=>true, :text=>"£100.00"},
          '', '', ''
        ]
      )
    end

    context 'when there are adjustments' do
      let(:adjustment_comment) { 'something' }

      it 'returns an array with the correct fields' do
        expected_fields = [
          "Type",
          {:numeric=>true, :text=>"£100.00"},
          {:numeric=>true, :text=>"£0.00"},
          {:numeric=>true, :text=>"£100.00"},
          {:numeric=>true, :text=>"£0.00"},
          {:numeric=>true, :text=>"£0.00"},
          {:numeric=>true, :text=>"£0.00"},
        ]
        expect(disbursement.table_fields).to eq(expected_fields)
      end
    end
  end
end
