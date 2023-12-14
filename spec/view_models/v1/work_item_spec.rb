require 'rails_helper'

RSpec.describe V1::WorkItem do
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

  describe 'table_fields' do
    let(:params) do
      {
        'work_type' => { 'en' => 'Waiting', 'value' => 'waiting' },
        'time_spent' => 161,
        'uplift' => 0,
        'pricing' => 24.0,
        'adjustments' => adjustments
      }
    end

    before do
      allow(CostCalculator).to receive(:cost).and_return(10.0)
    end

    it 'returns the fields for the table display' do
      expect(subject.table_fields).to eq(['Waiting', '0%', '£10.00', '', ''])
    end

    context 'when adjustments exists' do
      let(:adjustments) { [build(:event, :edit_work_item_uplift)] }

      it 'also renders caseworker values' do
        expect(subject.table_fields).to eq(['Waiting', '20%', '£10.00', '0%', '£10.00'])
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

  describe 'provider_requested_time_spent' do
    let(:params) do
      {
        'time_spent' => 100,
        'uplift' => 0,
        'pricing' => 24.0,
        'adjustments' => adjustments
      }
    end

    let(:adjustments) { [build(:event, :edit_work_item_time_spent)] }

    it 'shows the correct provider requested time spent' do
      expect(subject.provider_requested_time_spent).to eq(171)
    end
  end

  describe 'caseworker_amount' do
    let(:params) do
      {
        'time_spent' => 171,
        'uplift' => 0,
        'pricing' => 24.0,
        'adjustments' => adjustments
      }
    end

    let(:adjustments) { [build(:event, :edit_work_item_uplift)] }

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
        'adjustments' => adjustments,
        'vat_rate' => 0.2,
      }
    end

    let(:adjustments) { [build(:event, :edit_work_item_uplift)] }

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

  describe 'provider_requested_uplift' do
    let(:params) do
      {
        'time_spent' => 171,
        'uplift' => 0,
        'pricing' => 24.0,
        'adjustments' => adjustments
      }
    end

    let(:adjustments) { [build(:event, :edit_work_item_uplift)] }

    it 'shows the correct provider requested uplift' do
      expect(subject.provider_requested_uplift).to eq(20)
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
        let(:adjustments) { [build(:event, :edit_work_item_uplift)] }

        it { expect(subject).to be_uplift }
      end
    end
  end

  describe '#form_attributes' do
    let(:adjustments) { [] }
    let(:params) do
      {
        'work_type' => { 'en' => 'Waiting', 'value' => 'waiting' },
        'time_spent' => 161,
        'uplift' => 0,
        'pricing' => 24.0,
        'adjustments' => adjustments
      }
    end

    it 'extracts data for form initialization' do
      expect(subject.form_attributes).to eq(
        'explanation' => nil,
        'time_spent' => 161,
        'uplift' => 0
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
          'time_spent' => 161,
          'uplift' => 0
        )
      end
    end
  end

  describe 'attendance' do
    context 'when work type is attendance' do
      it 'is true' do
        expect(with_work_type('attendance_with_counsel')).to be_attendance
        expect(with_work_type('attendance_without_counsel')).to be_attendance
      end
    end

    context 'when work type is not attendance' do
      it 'is false' do
        expect(with_work_type('preparation')).not_to be_attendance
        expect(with_work_type('advocacy')).not_to be_attendance
        expect(with_work_type('travel')).not_to be_attendance
        expect(with_work_type('waiting')).not_to be_attendance
      end
    end

    def with_work_type(work_type)
      described_class.new(
        'work_type' => {
          'value' => work_type,
          'en' => work_type.capitalize
        }
      )
    end
  end

  describe '#provider_fields' do
    let(:params) do
      {
        'completed_on' => Time.zone.local(2022, 12, 14, 13, 0o2).to_s,
        'time_spent' => 171,
        'uplift' => 0,
        'pricing' => 24.0,
        'firm_office' => { 'vat_registered' => vat_registered },
        'adjustments' => adjustments,
        'vat_rate' => 0.2,
        'fee_earner' => 'JGB'
      }
    end

    let(:adjustments) { [build(:event, :edit_work_item_uplift)] }

    context 'when vat registered' do
      let(:vat_registered) { 'yes' }

      it 'calculates the correct provider requested amount' do
        expect(subject.provider_fields).to eq(
          '.date' => '14 December 2022',
          '.time_spent' => '2 Hrs 51 Mins',
          '.fee_earner' => 'JGB',
          '.uplift_claimed' => '20%',
          '.vat' => '20%',
          '.total_claimed_inc_vate' => '£98.50',
        )
      end
    end

    context 'when not vat registered' do
      let(:vat_registered) { 'no' }

      it 'calculates the correct provider requested amount' do
        expect(subject.provider_fields).to eq(
          '.date' => '14 December 2022',
          '.time_spent' => '2 Hrs 51 Mins',
          '.fee_earner' => 'JGB',
          '.uplift_claimed' => '20%',
          '.total_claimed' => '£82.08',
        )
      end
    end
  end
end
