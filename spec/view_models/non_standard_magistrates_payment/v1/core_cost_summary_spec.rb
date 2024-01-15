require 'rails_helper'

RSpec.describe NonStandardMagistratesPayment::V1::CoreCostSummary do
  subject { described_class.new(claim:) }

  let(:claim) do
    build(:claim).tap do |claim|
      claim.data.merge!('letters_and_calls' => letters_and_calls, 'work_items' => work_items)
    end
  end
  let(:letters_and_calls) do
    [
      { 'type' => { 'en' => 'Letters' }, 'count' => 10, 'pricing' => 4.0 },
      { 'type' => { 'en' => 'Calls' }, 'count' => 5, 'pricing' => 4.0 }
    ]
  end
  let(:work_items) { [{ data: 1 }] }

  before do
    allow(BaseViewModel).to receive(:build).and_call_original
    allow(BaseViewModel).to receive(:build).with(:work_item, anything, anything).and_return(v1_work_items)
  end

  describe '#table_fields' do
    context 'when a single work item exists' do
      let(:v1_work_items) do
        [
          instance_double(NonStandardMagistratesPayment::V1::WorkItem,
                          work_type: mock_translated('advocacy'),
                          time_spent: 20,
           provider_requested_time_spent: 20,
           provider_requested_amount_inc_vat: 100.0,
           caseworker_amount_inc_vat: 80.00,
           firm_office: { 'vat_registered' => 'no' })
        ]
      end

      it 'includes the letters and calls rows' do
        expect(subject.table_fields).to include(['Letters', '£40.00', ''], ['Calls', '£20.00', ''])
      end

      context 'when letters and calls proposed costs are zero' do
        let(:letters_and_calls) do
          [
            { 'type' => { 'en' => 'Letters' }, 'count' => 0, 'pricing' => 4.04 },
            { 'type' => { 'en' => 'Calls' }, 'count' => 0, 'pricing' => 4.04 }
          ]
        end

        it 'does not include them' do
          expect(subject.table_fields).to eq([['Advocacy', '£80.00', '20min']])
        end
      end

      it 'builds the view model' do
        subject.summed_fields
        expect(BaseViewModel).to have_received(:build).with(
          :work_item, claim, 'work_items'
        )
      end

      it 'includes the summed table field row' do
        expect(subject.table_fields).to include(['Advocacy', '£80.00', '20min'])
      end
    end

    context 'when multiple work item of diffent types exists' do
      let(:v1_work_items) do
        [
          instance_double(NonStandardMagistratesPayment::V1::WorkItem,
                          work_type: mock_translated('advocacy'), time_spent: 20,
                          provider_requested_time_spent: 20,
                          provider_requested_amount_inc_vat: 100.0, caseworker_amount_inc_vat: 80.00,
                          firm_office: { 'vat_registered' => 'no' }),
          instance_double(NonStandardMagistratesPayment::V1::WorkItem,
                          work_type: mock_translated('preparation'), time_spent: 30,
                          provider_requested_time_spent: 20,
                          provider_requested_amount_inc_vat: 110.0, caseworker_amount_inc_vat: 90.00,
                          firm_office: { 'vat_registered' => 'no' })
        ]
      end

      it 'returns a single table field row' do
        expect(subject.table_fields).to include(
          ['Advocacy', '£80.00', '20min'],
          ['Preparation', '£90.00', '30min']
        )
      end
    end

    context 'when waiting and travel work items exist' do
      let(:v1_work_items) do
        [
          instance_double(NonStandardMagistratesPayment::V1::WorkItem,
                          work_type: mock_translated('travel'), time_spent: 20,
                          provider_requested_time_spent: 20,
                          provider_requested_amount_inc_vat: 100.0, caseworker_amount_inc_vat: 80.00,
                          firm_office: { 'vat_registered' => 'no' }),
          instance_double(NonStandardMagistratesPayment::V1::WorkItem,
                          work_type: mock_translated('waiting'), time_spent: 20,
                          provider_requested_time_spent: 20,
                          provider_requested_amount_inc_vat: 100.0, caseworker_amount_inc_vat: 80.00,
                          firm_office: { 'vat_registered' => 'no' }),
          instance_double(NonStandardMagistratesPayment::V1::WorkItem,
                          work_type: mock_translated('preparation'), time_spent: 30,
                          provider_requested_time_spent: 20,
                        provider_requested_amount_inc_vat: 110.0, caseworker_amount_inc_vat: 90.00,
                          firm_office: { 'vat_registered' => 'no' })
        ]
      end

      it 'they are not returned' do
        expect(subject.table_fields.map(&:first)).to eq(%w[Preparation Letters Calls])
      end
    end

    context 'when multiple work item of the same types exists' do
      let(:v1_work_items) do
        [
          instance_double(NonStandardMagistratesPayment::V1::WorkItem,
                          work_type: mock_translated('advocacy'), time_spent: 20,
                          provider_requested_time_spent: 20,
                          provider_requested_amount_inc_vat: 100.0, caseworker_amount_inc_vat: 80.00,
                          firm_office: { 'vat_registered' => 'no' }),
          instance_double(NonStandardMagistratesPayment::V1::WorkItem,
                          work_type: mock_translated('advocacy'), time_spent: 30,
                          provider_requested_time_spent: 20,
                          provider_requested_amount_inc_vat: 110.0, caseworker_amount_inc_vat: 90.00,
                          firm_office: { 'vat_registered' => 'no' })
        ]
      end

      it 'includes a summed table field row' do
        expect(subject.table_fields).to include(['Advocacy', '£170.00', '50min'])
      end
    end
  end

  describe '#summed_fields' do
    before do
      allow(BaseViewModel).to receive(:build).and_call_original
      allow(BaseViewModel).to receive(:build).with(:work_item, anything, anything).and_return(v1_work_items)
    end

    context 'when a single work item exists' do
      let(:v1_work_items) do
        [
          instance_double(NonStandardMagistratesPayment::V1::WorkItem,
                          work_type: mock_translated('advocacy'), time_spent: 20,
                       provider_requested_time_spent: 20,
                       provider_requested_amount_inc_vat: 100.0, caseworker_amount_inc_vat: 80.00,
                       firm_office: { 'vat_registered' => 'no' })
        ]
      end

      it 'builds a WorkType record to use in the calculations' do
        subject.summed_fields
        expect(BaseViewModel).to have_received(:build).with(
          :work_item, claim, 'work_items'
        )
      end

      it 'returns the summed time and cost' do
        expect(subject.summed_fields).to eq(['£140.00', ''])
      end
    end

    context 'when multiple work item of diffent types exists' do
      let(:v1_work_items) do
        [
          instance_double(NonStandardMagistratesPayment::V1::WorkItem,
                          work_type: mock_translated('advocacy'), time_spent: 20,
                         provider_requested_time_spent: 20,
                         provider_requested_amount_inc_vat: 100.0, caseworker_amount_inc_vat: 80.00,
                         firm_office: { 'vat_registered' => 'no' }),
          instance_double(NonStandardMagistratesPayment::V1::WorkItem,
                          work_type: mock_translated('travel'), time_spent: 30,
                          provider_requested_time_spent: 30,
                          provider_requested_amount_inc_vat: 100.0, caseworker_amount_inc_vat: 80.00,
                          firm_office: { 'vat_registered' => 'no' })
        ]
      end

      it 'returns the summed cost' do
        expect(subject.summed_fields).to eq(['£140.00', ''])
      end
    end

    context 'when multiple work item of the same types exists' do
      let(:v1_work_items) do
        [
          instance_double(NonStandardMagistratesPayment::V1::WorkItem,
                          work_type: mock_translated('advocacy'), time_spent: 20,
                          provider_requested_time_spent: 20,
                          provider_requested_amount_inc_vat: 100.0, caseworker_amount_inc_vat: 80.00,
                          firm_office: { 'vat_registered' => 'no' }),
          instance_double(NonStandardMagistratesPayment::V1::WorkItem,
                          work_type: mock_translated('advocacy'), time_spent: 30,
                          provider_requested_time_spent: 30,
                           provider_requested_amount_inc_vat: 100.0, caseworker_amount_inc_vat: 80.00,
                          firm_office: { 'vat_registered' => 'no' })
        ]
      end

      it 'returns the summed cost' do
        expect(subject.summed_fields).to eq(['£220.00', ''])
      end
    end
  end
end
