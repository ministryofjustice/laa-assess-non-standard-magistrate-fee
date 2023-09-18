require 'rails_helper'

RSpec.describe V1::WorkItemsSummary do
  subject { described_class.new(work_items:) }

  before do
    allow(CostCalculator).to receive(:cost).and_return(100.0)
  end

  describe '#table_fields' do
    context 'when a single work item exists' do
      let(:work_items) { [{ 'work_type' => { 'en' => 'waiting' }, 'time_spent' => 20 }] }
      let(:work_item) { instance_double(V1::WorkItem, work_type: 'waiting', time_spent: 20) }

      before do
        allow(V1::WorkItem).to receive(:build_self).and_return(work_item)
      end

      it 'returns the summed time and cost' do
        subject.summed_fields
        expect(V1::WorkItem).to have_received(:build_self).with('work_type' => { 'en' => 'waiting' }, 'time_spent' => 20)
      end

      it 'returns a single table field row' do
        expect(subject.table_fields).to eq([['waiting', '20min', '£100.00']])
      end

      it 'calls the CostCalculator' do
        subject.table_fields

        expect(CostCalculator).to have_received(:cost).with(:work_item, work_item)
      end
    end

    context 'when multiple work item of diffent types exists' do
      let(:work_items) do
        [{ 'work_type' => { 'en' => 'waiting' }, 'time_spent' => 20 }, { 'work_type' => { 'en' => 'travel' }, 'time_spent' => 30 }]
      end

      it 'returns a single table field row' do
        expect(subject.table_fields).to eq([['waiting', '20min', '£100.00'], ['travel', '30min', '£100.00']])
      end
    end

    context 'when multiple work item of the same types exists' do
      let(:work_items) do
        [{ 'work_type' => { 'en' => 'waiting' }, 'time_spent' => 20 }, { 'work_type' => { 'en' => 'waiting' }, 'time_spent' => 30 }]
      end

      it 'returns a single table field row' do
        expect(subject.table_fields).to eq([['waiting', '50min', '£200.00']])
      end
    end
  end

  describe '#summed_fields' do
    context 'when a single work item exists' do
      let(:work_items) { [{ 'work_type' => { 'en' => 'waiting' }, 'time_spent' => 20 }] }
      let(:work_item) { instance_double(V1::WorkItem, work_type: 'waiting', time_spent: 20) }

      before do
        allow(V1::WorkItem).to receive(:build_self).and_return(work_item)
      end

      it 'returns the summed time and cost' do
        subject.summed_fields
        expect(V1::WorkItem).to have_received(:build_self).with('work_type' => { 'en' => 'waiting' }, 'time_spent' => 20)
      end

      it 'returns the summed time and cost' do
        expect(subject.summed_fields).to eq(['20min', '£100.00'])
      end

      it 'calls the CostCalculator' do
        subject.table_fields

        expect(CostCalculator).to have_received(:cost).with(:work_item, work_item)
      end
    end

    context 'when multiple work item of diffent types exists' do
      let(:work_items) do
        [{ 'work_type' =>{ 'en' =>  'waiting' }, 'time_spent' => 20 }, { 'work_type' => { 'en' => 'travel' }, 'time_spent' => 30 }]
      end

      it 'returns the summed time and cost' do
        expect(subject.summed_fields).to eq(['50min', '£200.00'])
      end
    end

    context 'when multiple work item of the same types exists' do
      let(:work_items) do
        [{ 'work_type' => { 'en' => 'waiting' }, 'time_spent' => 20 }, { 'work_type' => { 'en' => 'waiting' }, 'time_spent' => 30 }]
      end

      it 'returns the summed time and cost' do
        expect(subject.summed_fields).to eq(['50min', '£200.00'])
      end
    end
  end
end
