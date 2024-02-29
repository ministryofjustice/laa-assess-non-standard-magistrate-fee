require 'rails_helper'

RSpec.describe Nsm::V1::TravelAndWaiting do
  subject { described_class.new(params) }

  let(:claim) do
    build(:claim, firm_office: { 'vat_registered' => vat_registered }).tap do |claim|
      claim.data.merge!('work_items' => work_items)
    end
  end
  let(:params) do
    {
      'submission' => claim,
      'firm_office' => { 'vat_registered' => vat_registered },
    }
  end
  let(:vat_registered) { 'yes' }

  before do
    allow(CostCalculator).to receive(:cost).and_return(100.0)
  end

  describe '#vat_registered?' do
    let(:work_items) { [] }

    context 'when value is yes' do
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

  describe '#table_fields' do
    context 'when a single work item exists' do
      let(:work_items) do
        [{ 'work_type' => { 'en' => 'Travel', 'value' => 'travel' }, 'time_spent' => 20, 'vat_rate' => 0.2 }]
      end

      it 'includes the summed table field row' do
        expect(subject.table_fields).to include(
          ['Travel', '0 hours<br>20 minutes', '£120.00', '0 hours<br>20 minutes', '£120.00'],
        )
      end

      it 'calculates the total_cost' do
        expect(subject.total_cost).to eq('£120.00')
      end
    end

    context 'when multiple work item of diffent types exists' do
      let(:work_items) do
        [{ 'work_type' => { 'en' => 'Travel', 'value' => 'travel' }, 'time_spent' => 20, 'vat_rate' => 0.2 },
         { 'work_type' => { 'en' => 'Waiting', 'value' => 'waiting' }, 'time_spent' => 30, 'vat_rate' => 0.2 }]
      end

      it 'returns a single table field row' do
        expect(subject.table_fields).to include(
          ['Travel', '0 hours<br>20 minutes', '£120.00', '0 hours<br>20 minutes', '£120.00'],
          ['Waiting', '0 hours<br>30 minutes', '£120.00', '0 hours<br>30 minutes', '£120.00']
        )
      end

      it 'calculates the total_cost' do
        expect(subject.total_cost).to eq('£240.00')
      end
    end

    context 'when waiting and travel work items do not exist' do
      let(:work_items) do
        [{ 'work_type' => { 'en' => 'preparation', 'value' => 'preparation' }, 'time_spent' => 30, 'vat_rate' => 0.2 }]
      end

      it 'nothing is returned' do
        expect(subject.table_fields).to eq([])
      end

      it { expect(subject).not_to be_any }
    end

    context 'when multiple work item of the same types exists' do
      let(:work_items) do
        [{ 'work_type' => { 'en' => 'Travel', 'value' => 'travel' }, 'time_spent' => 20, 'vat_rate' => 0.2  },
         { 'work_type' => { 'en' => 'Travel', 'value' => 'travel' }, 'time_spent' => 30, 'vat_rate' => 0.2  }]
      end

      it 'includes a summed table field row' do
        expect(subject.table_fields).to include(
          ['Travel', '0 hours<br>50 minutes', '£240.00', '0 hours<br>50 minutes', '£240.00']
        )
      end
    end
  end
end
