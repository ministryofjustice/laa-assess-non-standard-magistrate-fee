require 'rails_helper'

RSpec.describe Nsm::V1::CoreCostSummary do
  subject { described_class.new(submission:) }

  let(:submission) do
    build(
      :claim,
      work_items: work_items.map(&:deep_stringify_keys),
      letters_and_calls: letters_and_calls,
      disbursements: disbursements.map(&:deep_stringify_keys),
      vat_registered: vat_registered,
      state: state
    )
  end
  let(:vat_registered) { 'no' }
  let(:letters_and_calls) { [] }
  let(:disbursements) do
    [{ total_cost_without_vat: 100.0, vat_amount: 0.0 }]
  end
  let(:work_items) { [] }
  let(:state) { 'submitted' }

  describe '#headers' do
    it 'retruns the translated headers' do
      expect(subject.headers).to eq(
        [
          { numeric: false, text: 'Items', width: 'govuk-!-width-one-quarter' },
          { numeric: true, text: 'Net cost claimed', width: nil },
          { numeric: true, text: 'VAT on claimed', width: nil },
          { numeric: true, text: 'Total claimed', width: nil },
          { numeric: true, text: 'Net cost allowed', width: nil },
          { numeric: true, text: 'VAT on allowed', width: nil },
          { numeric: true, text: 'Total allowed', width: nil }
        ]
      )
    end
  end

  describe '#table_fields' do
    context 'when a single work item exists' do
      let(:work_items) do
        [
          {
            work_type: 'advocacy',
            pricing: 10.0, time_spent_original: 600,
            time_spent: 480, adjustment_comment: 'Foo',
          }
        ]
      end

      it 'sums them into profit costs' do
        expect(subject.table_fields[0]).to eq(
          {
            allowed_gross_cost: { numeric: true, text: '£80.00' },
            allowed_net_cost: { numeric: true, text: '£80.00' }, allowed_vat: { numeric: true, text: '£0.00' },
            gross_cost: { numeric: true, text: '£100.00' }, name: { numeric: false, text: 'Profit costs', width: nil },
            net_cost: { numeric: true, text: '£100.00' }, vat: { numeric: true, text: '£0.00' }
          }
        )
      end
    end

    context 'when multiple work item of diffent types exists' do
      let(:work_items) do
        [
          {

            work_type: 'advocacy',
            pricing: 10.0, time_spent_original: 600, time_spent: 480, adjustment_comment: 'Foo',
          },
          {
            work_type: 'preparation',
            pricing: 10.0, time_spent_original: 660, time_spent: 540, adjustment_comment: 'Foo',
          }
        ]
      end

      it 'sums them all together in profit costs' do
        expect(subject.table_fields[0]).to eq(
          {
            allowed_gross_cost: { numeric: true, text: '£170.00' },
            allowed_net_cost: { numeric: true, text: '£170.00' }, allowed_vat: { numeric: true, text: '£0.00' },
            gross_cost: { numeric: true, text: '£210.00' }, name: { numeric: false, text: 'Profit costs', width: nil },
            net_cost: { numeric: true, text: '£210.00' }, vat: { numeric: true, text: '£0.00' }
          }
        )
      end
    end

    context 'when waiting and travel work items exist' do
      let(:work_items) do
        [
          {
            work_type: 'travel',
            pricing: 10.0, time_spent_original: 600, time_spent: 480, adjustment_comment: 'Foo',
          },
          {
            work_type: 'waiting',
            pricing: 10.0, time_spent_original: 600, time_spent: 480, adjustment_comment: 'Foo',
          },
          {
            work_type: 'preparation',
            pricing: 10.0, time_spent_original: 660, time_spent: 540, adjustment_comment: 'Foo',
          }
        ]
      end

      it 'they are returned' do
        expect(subject.table_fields[3]).to eq(
          {
            allowed_gross_cost: { numeric: true, text: '£80.00' }, allowed_net_cost: { numeric: true, text: '£80.00' },
            allowed_vat: { numeric: true, text: '£0.00' }, gross_cost: { numeric: true, text: '£100.00' },
            name: { numeric: false, text: 'Waiting', width: nil }, net_cost: { numeric: true, text: '£100.00' },
            vat: { numeric: true, text: '£0.00' }
          }
        )
        expect(subject.table_fields[2]).to eq(
          {
            allowed_gross_cost: { numeric: true, text: '£80.00' }, allowed_net_cost: { numeric: true, text: '£80.00' },
            allowed_vat: { numeric: true, text: '£0.00' }, gross_cost: { numeric: true, text: '£100.00' },
            name: { numeric: false, text: 'Travel', width: nil }, net_cost: { numeric: true, text: '£100.00' },
            vat: { numeric: true, text: '£0.00' }
          }
        )
      end
    end

    context 'when multiple work item of the same types exists' do
      let(:work_items) do
        [
          {
            work_type: 'advocacy',
            pricing: 10.0, time_spent_original: 600, time_spent: 480, adjustment_comment: 'Foo',
          },
          {
            work_type: 'advocacy',
            pricing: 10.0, time_spent_original: 660, time_spent: 540, adjustment_comment: 'Foo',
          }
        ]
      end

      it 'includes a summed table field row' do
        expect(subject.table_fields[0]).to eq(
          {
            allowed_gross_cost: { numeric: true, text: '£170.00' },
            allowed_net_cost: { numeric: true, text: '£170.00' }, allowed_vat: { numeric: true, text: '£0.00' },
            gross_cost: { numeric: true, text: '£210.00' }, name: { numeric: false, text: 'Profit costs', width: nil },
            net_cost: { numeric: true, text: '£210.00' }, vat: { numeric: true, text: '£0.00' }
          }
        )
      end
    end

    context 'when a work item has changed type' do
      let(:work_items) do
        [
          {
            work_type: 'advocacy',
            work_type_original: 'waiting',
            pricing: 10.0,
            pricing_original: 12.0,
            time_spent: 480, adjustment_comment: 'Foo',
          },
        ]
      end

      it 'includes shows something sensible for profit costs' do
        expect(subject.table_fields).to include(
          {
            allowed_gross_cost: { numeric: true, text: '£80.00' },
            allowed_net_cost: { numeric: true, text: '£80.00' }, allowed_vat: { numeric: true, text: '£0.00' },
            gross_cost: { numeric: true, text: '£0.00' }, name: { numeric: false, text: 'Profit costs', width: nil },
            net_cost: { numeric: true, text: '£0.00' }, vat: { numeric: true, text: '£0.00' }
          }
        )
      end

      it 'includes shows something sensible for waiting' do
        name_html = '<span title="One or more of these items were adjusted to be a different work item type.">' \
                    'Waiting</span> <sup><a href="#fn*">[*]</a></sup>'
        expect(subject.table_fields).to include(
          {
            allowed_gross_cost: { numeric: true, text: '£0.00' },
            allowed_net_cost: { numeric: true, text: '£0.00' },
            allowed_vat: { numeric: true, text: '£0.00' },
            gross_cost: { numeric: true, text: '£96.00' },
            name: { numeric: false, text: name_html },
            net_cost: { numeric: true, text: '£96.00' }, vat: { numeric: true, text: '£0.00' }
          }
        )
      end
    end

    context 'when disbursements exists - with adjustments' do
      let(:disbursements) do
        [
          {
            total_cost_without_vat: 0.0, total_cost_without_vat_original: 60.0,
            vat_amount: 0.0, vat_amount_original: 12.0
          }
        ]
      end

      it 'summs them all together in profit costs' do
        expect(subject.table_fields[1]).to eq(
          {
            allowed_gross_cost: { numeric: true, text: '£0.00' },
            allowed_net_cost: { numeric: true, text: '£0.00' }, allowed_vat: { numeric: true, text: '£0.00' },
            gross_cost: { numeric: true, text: '£72.00' }, name: { numeric: false, text: 'Disbursements', width: nil },
            net_cost: { numeric: true, text: '£60.00' }, vat: { numeric: true, text: '£12.00' }
          }
        )
      end
    end

    context 'when disbursements exists - without adjustments' do
      it 'summs them all together in profit costs' do
        expect(subject.table_fields[1]).to eq(
          {
            allowed_gross_cost: '', allowed_net_cost: '', allowed_vat: '',
            gross_cost: { numeric: true, text: '£100.00' }, name: { numeric: false, text: 'Disbursements', width: nil },
            net_cost: { numeric: true, text: '£100.00' }, vat: { numeric: true, text: '£0.00' }
          }
        )
      end
    end

    context 'when letters and calls exist' do
      let(:letters_and_calls) do
        [
          { 'type' => 'letters', 'count' => 10, 'pricing' => 4.0 },
          { 'type' => 'calls', 'count' => 5, 'pricing' => 4.0 }
        ]
      end

      it 'sums them into profit costs' do
        expect(subject.table_fields[0]).to eq(
          {
            allowed_gross_cost: '',
            allowed_net_cost: '',
            allowed_vat: '',
            gross_cost: { numeric: true, text: '£60.00' },
            name: { numeric: false, text: 'Profit costs', width: nil },
            net_cost: { numeric: true, text: '£60.00' },
            vat: { numeric: true, text: '£0.00' }
          }
        )
      end
    end

    context 'when dealing with figures involving recurring decimals' do
      let(:work_items) do
        Array.new(30) do
          {
            work_type: 'advocacy',
            pricing: 45.35, time_spent: 175,
          }
        end
      end

      it 'sums them into profit costs' do
        expect(subject.table_fields[0]).to include(
          gross_cost: { numeric: true, text: '£3,968.13' },
          name: { numeric: false, text: 'Profit costs', width: nil }
        )
      end
    end
  end

  describe '#formatted_summed_fields' do
    context 'when a single work item exists' do
      let(:work_items) do
        [
          {
            work_type: 'advocacy',
            pricing: 10.0, time_spent_original: 600, time_spent: 480, adjustment_comment: 'Foo',
          }
        ]
      end

      it 'returns the summed time and cost' do
        expect(subject.formatted_summed_fields).to eq(
          {
            allowed_gross_cost: { numeric: true, text: '£180.00' }, allowed_net_cost: { numeric: true, text: '£180.00' },
            allowed_vat: { numeric: true, text: '£0.00' }, gross_cost: { numeric: true, text: '£200.00' },
            name: { numeric: false, text: 'Total', width: nil }, net_cost: { numeric: true, text: '£200.00' },
            vat: { numeric: true, text: '£0.00' }
          }
        )
      end
    end

    context 'when no adjustments have been made' do
      let(:work_items) do
        [
          {
            work_type: 'advocacy',
            pricing: 10.0, time_spent: 480,
          }
        ]
      end

      it 'returns the summed time and cost' do
        expect(subject.formatted_summed_fields).to eq(
          {
            allowed_gross_cost: '', allowed_net_cost: '', allowed_vat: '', gross_cost: { numeric: true, text: '£180.00' },
            name: { numeric: false, text: 'Total', width: nil }, net_cost: { numeric: true, text: '£180.00' },
            vat: { numeric: true, text: '£0.00' }
          }
        )
      end
    end

    context 'when firm is VAT registered' do
      let(:vat_registered) { 'yes' }
      let(:work_items) do
        [
          {
            work_type: 'advocacy',
            pricing: 10.0, time_spent: 480,
          }
        ]
      end

      it 'returns the summed time and cost' do
        expect(subject.formatted_summed_fields).to eq(
          {
            allowed_gross_cost: '', allowed_net_cost: '', allowed_vat: '', gross_cost: { numeric: true, text: '£196.00' },
            name: { numeric: false, text: 'Total', width: nil }, net_cost: { numeric: true, text: '£180.00' },
            vat: { numeric: true, text: '£16.00' }
          }
        )
      end
    end

    context 'when multiple work item of diffent types exists' do
      let(:work_items) do
        [
          {
            work_type: 'advocacy',
            pricing: 10.0, time_spent_original: 600, time_spent: 480, adjustment_comment: 'Foo',
          },
          {
            work_type: 'travel',
            pricing: 10.0, time_spent_original: 600, time_spent: 480, adjustment_comment: 'Foo',
          }
        ]
      end

      it 'returns the summed cost' do
        expect(subject.formatted_summed_fields).to eq(
          {
            allowed_gross_cost: { numeric: true, text: '£260.00' }, allowed_net_cost: { numeric: true, text: '£260.00' },
            allowed_vat: { numeric: true, text: '£0.00' }, gross_cost: { numeric: true, text: '£300.00' },
            name: { numeric: false, text: 'Total', width: nil }, net_cost: { numeric: true, text: '£300.00' },
            vat: { numeric: true, text: '£0.00' }
          }
        )
      end
    end

    context 'when multiple work item of the same types exists' do
      let(:work_items) do
        [
          {
            work_type: 'advocacy',
                          pricing: 10.0, time_spent_original: 600, time_spent: 480, adjustment_comment: 'Foo',
          },
          {
            work_type: 'advocacy',
                           pricing: 10.0, time_spent_original: 600, time_spent: 480, adjustment_comment: 'Foo',
          }
        ]
      end

      it 'returns the summed cost' do
        expect(subject.formatted_summed_fields).to eq(
          {
            allowed_gross_cost: { numeric: true, text: '£260.00' }, allowed_net_cost: { numeric: true, text: '£260.00' },
            allowed_vat: { numeric: true, text: '£0.00' }, gross_cost: { numeric: true, text: '£300.00' },
            name: { numeric: false, text: 'Total', width: nil }, net_cost: { numeric: true, text: '£300.00' },
            vat: { numeric: true, text: '£0.00' }
          }
        )
      end
    end

    context 'when letters and calls exist' do
      let(:letters_and_calls) do
        [
          { 'type' => 'letters', 'count' => 10, 'pricing' => 4.0 },
          { 'type' => 'calls', 'count' => 5, 'pricing' => 4.0 }
        ]
      end

      it 'returns the summed cost' do
        expect(subject.formatted_summed_fields).to eq(
          {
            allowed_gross_cost: '',
            allowed_net_cost: '',
            allowed_vat: '',
            gross_cost: { numeric: true, text: '£160.00' },
            name: { numeric: false, text: 'Total', width: nil },
            net_cost: { numeric: true, text: '£160.00' },
            vat: { numeric: true, text: '£0.00' }
          }
        )
      end
    end

    context 'when claim submission rejected' do
      let(:work_items) do
        [
          {
            work_type: 'advocacy',
            pricing: 10.0, time_spent: 480,
          }
        ]
      end
      let(:state) { 'rejected' }

      it 'returns the summed time and cost' do
        expect(subject.formatted_summed_fields).to eq(
          {
            allowed_gross_cost: { numeric: true, text: '£0.00' }, allowed_net_cost: { numeric: true, text: '£0.00' },
            allowed_vat: { numeric: true, text: '£0.00' }, gross_cost: { numeric: true, text: '£180.00' },
            name: { numeric: false, text: 'Total', width: nil }, net_cost: { numeric: true, text: '£180.00' },
            vat: { numeric: true, text: '£0.00' }
          }
        )
      end
    end

    context 'when claim submission granted' do
      let(:work_items) do
        [
          {
            work_type: 'advocacy',
            pricing: 10.0, time_spent: 480,
          }
        ]
      end
      let(:state) { 'granted' }

      it 'returns the summed time and cost' do
        expect(subject.formatted_summed_fields).to eq(
          {
            allowed_gross_cost: '', allowed_net_cost: '', allowed_vat: '', gross_cost: { numeric: true, text: '£180.00' },
            name: { numeric: false, text: 'Total', width: nil }, net_cost: { numeric: true, text: '£180.00' },
            vat: { numeric: true, text: '£0.00' }
          }
        )
      end
    end
  end
end
