require 'rails_helper'

RSpec.describe V1::LetterAndCall do
  subject { described_class.new(params) }

  let(:adjustments) { [] }

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
    let(:params) { { count: 1, uplift: 5, pricing: 10.0, adjustments: adjustments } }

    it 'calculates the correct provider requested amount' do
      expect(subject.provider_requested_amount).to eq(10.5)
    end

    context 'when adjustments are present' do
      let(:adjustments) { [build(:event, :edit_uplift), build(:event, :edit_count)] }

      it 'calulates the initial uplift' do
        expect(subject.provider_requested_amount).to eq(10.0 * 10.0 * 1.95)
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

  describe '#provider_requested_uplift' do
    context 'when uplift has a value' do
      let(:params) { { uplift: 5, adjustments: adjustments } }

      it 'returns the uplift amount as a percentage' do
        expect(subject.provider_requested_uplift).to eq(5)
      end

      context 'when adjustments are present' do
        let(:adjustments) { [build(:event, :edit_uplift)] }

        it 'calulates the initial uplift' do
          expect(subject.provider_requested_uplift).to eq(95)
        end
      end
    end

    context 'when uplift is nil' do
      let(:params) { { uplift: nil } }

      it 'returns 0% as the uplift amount' do
        expect(subject.provider_requested_uplift).to be_nil
      end
    end
  end

  describe '#provider_requested_count' do
    let(:params) { { count: 5, adjustments: adjustments } }

    it 'returns the uplift amount as a percentage' do
      expect(subject.provider_requested_count).to eq(5)
    end

    context 'when adjustments are present' do
      let(:adjustments) { [build(:event, :edit_count)] }

      it 'calulates the initial count' do
        expect(subject.provider_requested_count).to eq(10)
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

  describe '#caseworker_uplift' do
    let(:params) { { uplift: 5 } }

    it 'returns the uplift value' do
      expect(subject.caseworker_uplift).to eq(5)
    end
  end

  describe '#caseworker_count' do
    let(:params) { { count: 5 } }

    it 'returns the count value' do
      expect(subject.caseworker_count).to eq(5)
    end
  end

  describe '#allowed_amount' do
    let(:params) { { count: 1, uplift: 5, pricing: 10.0, adjustments: adjustments } }

    before do
      allow(CostCalculator).to receive(:cost).with(:letter_and_call, anything, :provider_requested)
                                             .and_return(10.0)
      allow(CostCalculator).to receive(:cost).with(:letter_and_call, anything, :caseworker)
                                             .and_return(20.0)
    end

    context 'when adjustments exists' do
      let(:adjustments) { [{ this: :thing }] }

      it 'returns the caseworker amount' do
        expect(subject.allowed_amount).to eq(20.0)
      end
    end

    context 'when adjustments do not exists' do
      let(:adjustments) { [] }

      it 'returns the provider supplied amount' do
        expect(subject.allowed_amount).to eq(10.0)
      end
    end
  end

  describe '#type_name' do
    let(:params) { { type: { 'en' => 'Letters', :value => 'll' } } }

    it 'returns the downcase translated type' do
      expect(subject.type_name).to eq('letters')
    end
  end

  describe '#form_attributes' do
    let(:adjustments) { [] }
    let(:params) do
      {
        type: { 'en' => 'Letters', 'value' => 'll' },
        count: 10,
        uplift: 15,
        adjustments: adjustments,
      }
    end

    it 'extracts data for form initialization' do
      expect(subject.form_attributes).to eq(
        'explanation' => nil,
        'count' => 10,
        'type' => 'll',
        'uplift' => 15,
      )
    end

    context 'when adjustments exists' do
      let(:adjustments) do
        [
          double(:first, details: { 'comment' => 'first adjustment' }),
          double(:second, details: { 'comment' => 'second adjustment' }),
        ]
      end

      it 'includes the previous adjustment comment' do
        expect(subject.form_attributes).to eq(
          'explanation' => 'second adjustment',
          'count' => 10,
          'type' => 'll',
          'uplift' => 15,
        )
      end
    end
  end

  describe '#table_fields' do
    let(:params) do
      {
        'type' => { 'en' => 'Letters', 'value' => 'letters' },
        'count' => 12,
        'uplift' => 0,
        'pricing' => 3.56,
        'adjustments' => adjustments,
      }
    end
    let(:adjustments) { [] }

    before do
      allow(CostCalculator).to receive(:cost).and_return(10.0)
    end

    it 'returns the fields for the table display' do
      expect(subject.table_fields).to eq(['Letters', '12', '0%', '£10.00', '', ''])
    end

    context 'when adjustments exist' do
      let(:adjustments) { [build(:event, :edit_uplift)] }

      it 'also renders caseworker values' do
        expect(subject.table_fields).to eq(['Letters', '12', '95%', '£10.00', '0%', '£10.00'])
      end
    end
  end

  describe '#uplift?' do
    context 'when provider supplied uplift is positive' do
      let(:params) { { uplift: 10 } }

      it { expect(subject).to be_uplift }
    end

    context 'when uplift is zero' do
      let(:params) { { uplift: 0, adjustments: adjustments } }
      let(:adjustments) { [] }

      it { expect(subject).not_to be_uplift }

      context 'but has adjustments' do
        let(:adjustments) { [build(:event, :edit_uplift)] }

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
        'pricing' => 3.56,
        'firm_office' => { 'vat_registered' => vat_registered },
        'adjustments' => adjustments,
        'vat_rate' => 0.2,
      }
    end

    let(:adjustments) { [build(:event, :edit_work_item_uplift)] }

    context 'when vat registered' do
      let(:vat_registered) { 'yes' }

      it 'calculates the correct provider requested amount' do
        expect(subject.provider_fields).to eq(
          '.number' => '12',
          '.rate' => '£3.56',
          '.uplift_requested' => '20%',
          '.vat' => '20%',
          '.total_claimed_inc_vate' => '£61.51',
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
end
