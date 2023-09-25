require 'rails_helper'

RSpec.describe V1::CoreCostSummary do
  subject { described_class.new(work_items:, letters_and_calls:) }

  before do
    allow(CostCalculator).to receive(:cost).and_return(100.0)
  end

  let(:letters_and_calls) do
    [
      { 'type' => { 'en' => 'Letters', 'count' => 10, 'pricing' => 4.04 } },
      { 'type' => { 'en' => 'Calls', 'count' => 5, 'pricing' => 4.04 } }
    ]
  end

  describe '#table_fields' do
    context 'when a single work item exists' do
      let(:work_items) { [{ 'work_type' => { 'en' => 'advocacy' }, 'time_spent' => 20 }] }
      let(:work_item) { instance_double(V1::WorkItem, work_type: 'advocacy', time_spent: 20) }

      before do
        allow(V1::WorkItem).to receive(:build_self).and_return(work_item)
      end

      it 'includes the letters and calls rows' do
        expect(subject.table_fields).to include(['Letters', '£100.00', ''], ['Calls', '£100.00', ''])
      end

      it 'builds the view model' do
        subject.summed_fields
        expect(V1::WorkItem).to have_received(:build_self).with('work_type' => { 'en' => 'advocacy' },
                                                                'time_spent' => 20)
      end

      it 'includes the summed table field row' do
        expect(subject.table_fields).to include(['advocacy', '£100.00', '20min'])
      end

      it 'calls the CostCalculator' do
        subject.table_fields

        expect(CostCalculator).to have_received(:cost).with(:work_item, work_item)
      end
    end

    context 'when multiple work item of diffent types exists' do
      let(:work_items) do
        [{ 'work_type' => { 'en' => 'advocacy' }, 'time_spent' => 20 },
         { 'work_type' => { 'en' => 'preparation' }, 'time_spent' => 30 }]
      end

      it 'returns a single table field row' do
        expect(subject.table_fields).to include(['advocacy', '£100.00', '20min'], ['preparation', '£100.00', '30min'])
      end
    end

    context 'when waiting and travel work items exist' do
      let(:work_items) do
        [{ 'work_type' => { 'en' => 'travel' }, 'time_spent' => 20 },
         { 'work_type' => { 'en' => 'waiting' }, 'time_spent' => 20 },
         { 'work_type' => { 'en' => 'preparation' }, 'time_spent' => 30 }]
      end

      it 'they are not returned' do
        expect(subject.table_fields.map(&:first)).to eq(%w[preparation Letters Calls])
      end
    end

    context 'when multiple work item of the same types exists' do
      let(:work_items) do
        [{ 'work_type' => { 'en' => 'advocacy' }, 'time_spent' => 20 },
         { 'work_type' => { 'en' => 'advocacy' }, 'time_spent' => 30 }]
      end

      it 'includes a summed table field row' do
        expect(subject.table_fields).to include(['advocacy', '£200.00', '50min'])
      end
    end
  end

  describe '#summed_fields' do
    context 'when a single work item exists' do
      let(:work_items) { [{ 'work_type' => { 'en' => 'advocacy' }, 'time_spent' => 20 }] }
      let(:work_item) { instance_double(V1::WorkItem, work_type: 'advocacy', time_spent: 20) }

      before do
        allow(V1::WorkItem).to receive(:build_self).and_return(work_item)
      end

      it 'builds a WorkType record to use in the calculations' do
        subject.summed_fields
        expect(V1::WorkItem).to have_received(:build_self).with('work_type' => { 'en' => 'advocacy' },
                                                                'time_spent' => 20)
      end

      it 'returns the summed time and cost' do
        expect(subject.summed_fields).to eq(['£300.00', ''])
      end

      it 'calls the CostCalculator' do
        subject.table_fields

        expect(CostCalculator).to have_received(:cost).with(:work_item, work_item)
      end
    end

    context 'when multiple work item of diffent types exists' do
      let(:work_items) do
        [{ 'work_type' => { 'en' => 'advocacy' }, 'time_spent' => 20 },
         { 'work_type' => { 'en' => 'travel' }, 'time_spent' => 30 }]
      end

      it 'returns the summed cost' do
        expect(subject.summed_fields).to eq(['£300.00', ''])
      end
    end

    context 'when multiple work item of the same types exists' do
      let(:work_items) do
        [{ 'work_type' => { 'en' => 'advocacy' }, 'time_spent' => 20 },
         { 'work_type' => { 'en' => 'advocacy' }, 'time_spent' => 30 }]
      end

      it 'returns the summed cost' do
        expect(subject.summed_fields).to eq(['£400.00', ''])
      end
    end
  end
end
