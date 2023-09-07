require 'rails_helper'

RSpec.describe V1::WorkItemsSummary do
  subject { described_class.new(work_items:) }

  before do
    allow(CostCalculator).to receive(:cost).and_return(100.0)
  end

  describe '#table_fields' do
    context 'when a single work item exists' do
      let(:work_items) { [{ 'work_type' => 'waiting', 'time_spent' => 20 }] }

      it 'returns a single table field row' do
        expect(subject.table_fields).to eq([['waiting', '20min', '£100.00']])
      end

      it 'calls the CostCalculator' do
        subject.table_fields

        expect(CostCalculator).to have_received(:cost).with(:work_item, 'work_type' => 'waiting', 'time_spent' => 20)
      end
    end

    context 'when multiple work item of diffent types exists' do
      let(:work_items) do
        [{ 'work_type' => 'waiting', 'time_spent' => 20 }, { 'work_type' => 'travel', 'time_spent' => 30 }]
      end

      it 'returns a single table field row' do
        expect(subject.table_fields).to eq([['waiting', '20min', '£100.00'], ['travel', '30min', '£100.00']])
      end
    end

    context 'when multiple work item of the same types exists' do
      let(:work_items) do
        [{ 'work_type' => 'waiting', 'time_spent' => 20 }, { 'work_type' => 'waiting', 'time_spent' => 30 }]
      end

      it 'returns a single table field row' do
        expect(subject.table_fields).to eq([['waiting', '50min', '£200.00']])
      end
    end
  end

  describe '#summed_fields' do
    context 'when a single work item exists' do
      let(:work_items) { [{ 'work_type' => 'waiting', 'time_spent' => 20 }] }

      it 'returns the summed time and cost' do
        expect(subject.summed_fields).to eq(['20min', '£100.00'])
      end

      it 'calls the CostCalculator' do
        subject.table_fields

        expect(CostCalculator).to have_received(:cost).with(:work_item, 'work_type' => 'waiting', 'time_spent' => 20)
      end
    end

    context 'when multiple work item of diffent types exists' do
      let(:work_items) do
        [{ 'work_type' => 'waiting', 'time_spent' => 20 }, { 'work_type' => 'travel', 'time_spent' => 30 }]
      end

      it 'returns the summed time and cost' do
        expect(subject.summed_fields).to eq(['50min', '£200.00'])
      end
    end

    context 'when multiple work item of the same types exists' do
      let(:work_items) do
        [{ 'work_type' => 'waiting', 'time_spent' => 20 }, { 'work_type' => 'waiting', 'time_spent' => 30 }]
      end

      it 'returns the summed time and cost' do
        expect(subject.summed_fields).to eq(['50min', '£200.00'])
      end
    end
  end
end
