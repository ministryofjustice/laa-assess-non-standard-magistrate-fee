require 'rails_helper'

RSpec.describe Nsm::V1::LetterAndCall do
  subject { described_class.new(params) }

  describe '#vat_registered?' do
    let(:params) do
      {
        'firm_office' => { 'vat_registered' => vat_registered },
      }
    end

    context 'when value is yes' do
      let(:vat_registered) { 'yes' }

      it { expect(subject).to be_vat_registered }
    end

    context 'when value is no' do
      let(:vat_registered) { 'no' }

      it { expect(subject).not_to be_vat_registered }
    end

    context 'when value is blank' do
      let(:vat_registered) { '' }

      it { expect(subject).not_to be_vat_registered }
    end
  end

  describe '#provider_requested_amount' do
    let(:params) { { count_original: 1, uplift_original: 10, pricing: 10.5 } }

    it 'calculates the correct provider requested amount' do
      expect(subject.provider_requested_amount).to eq(11.55)
    end

    context 'when originals are not set' do
      let(:params) { { count: 10, uplift: 10, pricing: 1.95 } }

      it 'calulates the initial uplift' do
        expect(subject.provider_requested_amount).to eq(10.0 * 1.1 * 1.95)
      end
    end
  end

  describe 'provider_requested_amount_inc_vat' do
    let(:params) do
      {
        :count => 1,
        :uplift => 5,
        :pricing => 10.0,
        'firm_office' => { 'vat_registered' => vat_registered },
        'vat_rate' => 0.2,
      }
    end

    context 'when vat registered' do
      let(:vat_registered) { 'yes' }

      it 'calculates the correct provider requested amount' do
        expect(subject.provider_requested_amount_inc_vat).to eq(12.6)
      end
    end

    context 'when not vat registered' do
      let(:vat_registered) { 'no' }

      it 'calculates the correct provider requested amount' do
        expect(subject.provider_requested_amount_inc_vat).to eq(10.5)
      end
    end
  end

  describe '#original_uplift' do
    context 'when uplift_original has a value' do
      let(:params) { { uplift_original: 5, uplift: 10 } }

      it 'returns the uplift amount as a percentage' do
        expect(subject.original_uplift).to eq(5)
      end

      context 'when there is no original value' do
        let(:params) { { uplift: 10 } }

        it 'uses the standard uplift' do
          expect(subject.original_uplift).to eq(10)
        end
      end
    end
  end

  describe '#original_count' do
    context 'when count_original has a value' do
      let(:params) { { count_original: 5, count: 10 } }

      it 'returns the count amount as a percentage' do
        expect(subject.original_count).to eq(5)
      end

      context 'when there is no original value' do
        let(:params) { { count: 10 } }

        it 'uses the standard count' do
          expect(subject.original_count).to eq(10)
        end
      end
    end
  end

  describe '#caseworker_amount' do
    let(:params) { { count: 1, uplift: 5, pricing: 10.0 } }

    it 'calculates the correct caseworker amount' do
      expect(subject.caseworker_amount).to eq(10.5)
    end
  end

  describe 'caseworker_amount_inc_vat' do
    let(:params) do
      {
        :count => 1,
        :uplift => 5,
        :pricing => 10.0,
        'firm_office' => { 'vat_registered' => vat_registered },
        'vat_rate' => 0.2,
      }
    end

    context 'when vat registered' do
      let(:vat_registered) { 'yes' }

      it 'calculates the correct provider requested amount' do
        expect(subject.caseworker_amount_inc_vat).to eq(12.6)
      end
    end

    context 'when not vat registered' do
      let(:vat_registered) { 'no' }

      it 'calculates the correct provider requested amount' do
        expect(subject.caseworker_amount_inc_vat).to eq(10.5)
      end
    end
  end

  describe '#uplift' do
    let(:params) { { uplift: 5 } }

    it 'returns the uplift value' do
      expect(subject.uplift).to eq(5)
    end
  end

  describe '#count' do
    let(:params) { { count: 5 } }

    it 'returns the count value' do
      expect(subject.count).to eq(5)
    end
  end

  describe '#type_name' do
    let(:params) { { type: { 'en' => 'Letters', :value => 'll' } } }

    it 'returns the downcase translated type' do
      expect(subject.type_name).to eq('letters')
    end
  end

  describe '#form_attributes' do
    let(:params) do
      {
        type: { 'en' => 'Letters', 'value' => 'll' },
        count: 10,
        uplift: 15,
        adjustment_comment: 'second adjustment'
      }
    end

    it 'extracts data for form initialization' do
      expect(subject.form_attributes).to eq(
        'explanation' => 'second adjustment',
        'count' => 10,
        'type' => 'll',
        'uplift' => 15,
      )
    end
  end

  describe '#table_fields' do
    let(:params) do
      {
        'type' => { 'en' => 'Letters', 'value' => 'letters' },
        'count' => 12,
        'uplift' => 0,
        'pricing' => 3.56,
      }
    end

    it 'returns the fields for the table display' do
      expect(subject.table_fields).to eq(
        [
          'Letters',
          { numeric: true, text: '12' },
          { numeric: true, text: '0%' },
          { numeric: true, text: '£42.72' },
          ''
        ]
      )
    end

    context 'when adjustments exist' do
      let(:params) do
        {
          'type' => { 'en' => 'Letters', 'value' => 'letters' },
          'count' => 12,
          'uplift' => 0,
          'pricing' => 3.56,
          'count_original' => 15,
          'uplift_original' => 95,
          'adjustment_comment' => 'something'
        }
      end

      it 'also renders caseworker values' do
        expect(subject.table_fields).to eq(
          [
            'Letters',
            { numeric: true, text: '15' },
            { numeric: true, text: '95%' },
            { numeric: true, text: '£104.13' },
            { numeric: true, text: '£42.72' }
          ]
        )
      end
    end
  end

  describe '#adjusted_table_fields' do
    let(:params) do
      {
        'type' => { 'en' => 'Letters', 'value' => 'letters' },
        'count' => 12,
        'uplift' => 0,
        'pricing' => 3.56,
        'count_original' => 15,
        'uplift_original' => 95,
        'adjustment_comment' => 'something'
      }
    end

    it 'also renders caseworker values' do
      expect(subject.adjusted_table_fields).to eq(
        [
          'Letters',
          'something',
          { numeric: true, text: '12' },
          { numeric: true, text: '0%' },
          { numeric: true, text: '£42.72' }
        ]
      )
    end
  end

  describe '#uplift?' do
    context 'when provider supplied uplift is positive' do
      let(:params) { { uplift: 10 } }

      it { expect(subject).to be_uplift }
    end

    context 'when uplift is zero' do
      let(:params) { { uplift: 0 } }

      it { expect(subject).not_to be_uplift }

      context 'but was positive' do
        let(:params) { { uplift: 0, uplift_original: 1 } }

        it { expect(subject).to be_uplift }
      end
    end
  end

  describe '#provider_fields' do
    let(:params) do
      {
        'type' => { 'en' => 'Letters', 'value' => 'letters' },
        'count' => 12,
        'uplift' => 0,
        'uplift_original' => 20,
        'pricing' => 3.56,
        'firm_office' => { 'vat_registered' => vat_registered },
        'vat_rate' => 0.2,
      }
    end

    context 'when vat registered' do
      let(:vat_registered) { 'yes' }

      it 'only shows vat-exclusive amount' do
        expect(subject.provider_fields).to eq(
          '.number' => '12',
          '.rate' => '£3.56',
          '.uplift_requested' => '20%',
          '.total_claimed' => '£51.26',
        )
      end
    end

    context 'when not vat registered' do
      let(:vat_registered) { 'no' }

      it 'calculates the correct provider requested amount' do
        expect(subject.provider_fields).to eq(
          '.number' => '12',
          '.rate' => '£3.56',
          '.uplift_requested' => '20%',
          '.total_claimed' => '£51.26',
        )
      end
    end
  end

  describe '#id' do
    let(:params) do
      { 'type' => { 'en' => 'Letters', 'value' => 'letters' } }
    end

    it { expect(subject.id).to eq 'letters' }
  end

  describe 'backlink_path' do
    context 'when a change has been made' do
      let(:claim) { create(:claim) }
      let(:params) do
        {
          'type' => { 'en' => 'Letters', 'value' => 'letters' },
          'adjustment_comment' => 'test'
        }
      end

      it 'returns the expected path' do
        expected_path = Rails.application.routes.url_helpers.adjusted_nsm_claim_letters_and_calls_path(claim,
                                                                                                       anchor: subject.id)
        expect(subject.backlink_path(claim)).to eq(expected_path)
      end
    end

    context 'when no change has been made' do
      let(:claim) { create(:claim) }
      let(:params) do
        {
          'type' => { 'en' => 'Letters', 'value' => 'letters' },
        }
      end

      it 'returns the expected path' do
        expected_path = Rails.application.routes.url_helpers.nsm_claim_letters_and_calls_path(claim,
                                                                                              anchor: subject.id)
        expect(subject.backlink_path(claim)).to eq(expected_path)
      end
    end
  end
end
