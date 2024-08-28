require 'rails_helper'

RSpec.describe Nsm::V1::WorkItem do
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

  describe 'table fields' do
    let(:adjustment_comment) { 'something' }
    let(:params) do
      {
        'work_type' => { 'en' => 'Waiting', 'value' => 'waiting' },
        'completed_on' => Date.new(2024, 1, 1),
        'time_spent' => 161,
        'uplift' => 0,
        'uplift_original' => 20,
        'pricing' => 24.0,
        'adjustment_comment' => adjustment_comment
      }
    end

    describe '#reason' do
      it { expect(subject.reason).to eq('something') }
    end

    describe '#formatted_completed_on' do
      it { expect(subject.formatted_completed_on).to eq('1 Jan 2024') }
    end

    describe '#formatted_time_spent' do
      it {
        expect(subject.formatted_time_spent).to eq(
          '2<span class="govuk-visually-hidden"> hours</span>:41<span class="govuk-visually-hidden"> minutes</span>'
        )
      }
    end

    describe '#formatted_uplift' do
      it { expect(subject.formatted_uplift).to eq('20%') }
    end

    describe '#formatted_requested_amount' do
      it { expect(subject.formatted_requested_amount).to eq('£77.28') }
    end

    describe '#formatted_allowed_time_spent' do
      it {
        expect(subject.formatted_allowed_time_spent).to eq(
          '2<span class="govuk-visually-hidden"> hours</span>:41<span class="govuk-visually-hidden"> minutes</span>'
        )
      }
    end

    describe '#formatted_allowed_uplift' do
      it { expect(subject.formatted_allowed_uplift).to eq('0%') }
    end

    describe '#formatted_allowed_amount' do
      it { expect(subject.formatted_allowed_amount).to eq('£64.40') }

      context 'when no adjustments' do
        let(:adjustment_comment) { nil }

        it { expect(subject.formatted_allowed_amount).to eq('') }
      end
    end
  end

  describe 'provider_requested_amount' do
    let(:params) do
      {
        'time_spent' => 171,
        'uplift' => 10,
        'pricing' => 24.0
      }
    end

    it 'calculates the correct provider requested amount' do
      expect(subject.provider_requested_amount).to eq(75.24)
    end

    context 'when numbers might lead to floating point rounding errors' do
      let(:params) do
        {
          'time_spent' => 36,
          'uplift' => 0,
          'pricing' => 45.35
        }
      end

      it 'calculates the correct provider requested amount' do
        expect(subject.provider_requested_amount).to eq(27.21)
      end
    end
  end

  describe 'provider_requested_amount_inc_vat' do
    let(:params) do
      {
        'time_spent' => 171,
        'uplift' => 10,
        'pricing' => 24.0,
        'firm_office' => { 'vat_registered' => vat_registered },
        'vat_rate' => 0.2,
      }
    end

    context 'when vat registered' do
      let(:vat_registered) { 'yes' }

      it 'calculates the correct provider requested amount' do
        expect(subject.provider_requested_amount_inc_vat).to eq(90.288)
      end
    end

    context 'when not vat registered' do
      let(:vat_registered) { 'no' }

      it 'calculates the correct provider requested amount' do
        expect(subject.provider_requested_amount_inc_vat).to eq(75.24)
      end
    end
  end

  describe 'original_time_spent' do
    let(:params) do
      {
        'time_spent' => 100,
        'time_spent_original' => 171,
      }
    end

    it 'shows the correct provider requested time spent' do
      expect(subject.original_time_spent).to eq(171)
    end
  end

  describe 'caseworker_amount' do
    let(:params) do
      {
        'time_spent' => 171,
        'uplift' => 0,
        'pricing' => 24.0,
      }
    end

    it 'calculates the correct caseworker requested amount' do
      expect(subject.caseworker_amount).to eq(68.4)
    end
  end

  describe '#caseworker_amount_inc_vat' do
    let(:params) do
      {
        'time_spent' => 171,
        'uplift' => 0,
        'pricing' => 24.0,
        'firm_office' => { 'vat_registered' => vat_registered },
        'vat_rate' => 0.2,
      }
    end

    context 'when vat registered' do
      let(:vat_registered) { 'yes' }

      it 'calculates the correct provider requested amount' do
        expect(subject.caseworker_amount_inc_vat).to eq(82.08)
      end
    end

    context 'when not vat registered' do
      let(:vat_registered) { 'no' }

      it 'calculates the correct provider requested amount' do
        expect(subject.caseworker_amount_inc_vat).to eq(68.4)
      end
    end
  end

  describe 'original_uplift' do
    let(:params) do
      {
        'uplift' => 0,
        'uplift_original' => 20,
      }
    end

    it 'shows the correct provider requested uplift' do
      expect(subject.original_uplift).to eq(20)
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

      context 'but has adjustments' do
        let(:params) { { uplift: 0, uplift_original: 10 } }

        it { expect(subject).to be_uplift }
      end
    end
  end

  describe '#form_attributes' do
    let(:params) do
      {
        'work_type' => { 'en' => 'Waiting', 'value' => 'waiting' },
        'time_spent' => 161,
        'uplift' => 0,
        'pricing' => 24.0,
      }
    end

    it 'extracts data for form initialization' do
      expect(subject.form_attributes).to eq(
        'explanation' => nil,
        'time_spent' => 161,
        'uplift' => 0,
        'work_type_value' => 'waiting',
      )
    end

    context 'when adjustments exists' do
      let(:params) do
        {
          'work_type' => { 'en' => 'Waiting', 'value' => 'waiting' },
          'time_spent' => 161,
          'uplift' => 0,
          'pricing' => 24.0,
          'adjustment_comment' => 'second adjustment',
        }
      end

      it 'includes the previous adjustment comment' do
        expect(subject.form_attributes).to eq(
          'explanation' => 'second adjustment',
          'time_spent' => 161,
          'uplift' => 0,
          'work_type_value' => 'waiting',
        )
      end
    end
  end

  describe '#provider_fields' do
    let(:params) do
      {
        'completed_on' => Time.zone.local(2022, 12, 14, 13, 0o2).to_s,
        'time_spent' => 171,
        'uplift' => 0,
        'uplift_original' => 20,
        'pricing' => 24.0,
        'firm_office' => { 'vat_registered' => vat_registered },
        'vat_rate' => 0.2,
        'fee_earner' => 'JGB',
        'work_type' => { 'value' => 'waiting', 'en' => 'Waiting' },
      }
    end

    context 'when vat registered' do
      let(:vat_registered) { 'yes' }

      it 'calculates the correct provider requested amount' do
        expect(subject.provider_fields).to eq(
          '.work_type' => 'Waiting',
          '.date' => '14 December 2022',
          '.time_spent' => '2 hours 51 minutes',
          '.fee_earner' => 'JGB',
          '.uplift_claimed' => '20%',
          '.vat' => '20%',
          '.total_claimed_inc_vat' => '£98.50',
        )
      end
    end

    context 'when not vat registered' do
      let(:vat_registered) { 'no' }

      it 'calculates the correct provider requested amount' do
        expect(subject.provider_fields).to eq(
          '.work_type' => 'Waiting',
          '.date' => '14 December 2022',
          '.time_spent' => '2 hours 51 minutes',
          '.fee_earner' => 'JGB',
          '.uplift_claimed' => '20%',
          '.total_claimed' => '£82.08',
        )
      end
    end
  end
end
