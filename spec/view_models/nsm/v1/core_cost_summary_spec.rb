require 'rails_helper'

RSpec.describe Nsm::V1::CoreCostSummary do
  subject { described_class.new(submission:) }

  let(:submission) do
    build(
      :claim,
      state:,
      data:
    )
  end

  let(:data) do
    build(
      :nsm_data, claim_type: claim_type, include_youth_court_fee: include_youth_court_fee,
      include_youth_court_fee_original: include_youth_court_fee_original,
      youth_court: youth_court, plea_category: plea_category, rep_order_date: rep_order_date,
      work_items: work_items.map(&:deep_stringify_keys), letters_and_calls: letters_and_calls,
      disbursements: disbursements.map(&:deep_stringify_keys), vat_registered: vat_registered,
    )
  end

  let(:vat_registered) { 'no' }
  let(:letters_and_calls) { [] }
  let(:disbursements) do
    [{ total_cost_without_vat: 100.0, vat_amount: 0.0, disbursement_type: 'other' }]
  end
  let(:work_items) { [] }
  let(:state) { 'submitted' }
  let(:claim_type) { 'non_standard_magistrate' }
  let(:plea_category) { 'category_1a' }
  let(:youth_court) { 'yes' }
  let(:rep_order_date) { Date.new(2024, 12, 5) }
  let(:include_youth_court_fee) { false }
  let(:include_youth_court_fee_original) { nil }

  describe '#headers' do
    it 'returns the translated headers' do
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
            pricing: -1, time_spent_original: 600,
            time_spent: 480, adjustment_comment: 'Foo',
          }
        ]
      end

      it 'sums them into profit costs' do
        expect(subject.table_fields[0]).to eq(
          {
            allowed_gross_cost: { numeric: true, text: '£523.36' },
            allowed_net_cost: { numeric: true, text: '£523.36' }, allowed_vat: { numeric: true, text: '£0.00' },
            gross_cost: { numeric: true, text: '£654.20' }, name: { numeric: false, text: 'Profit costs', width: nil },
            net_cost: { numeric: true, text: '£654.20' }, vat: { numeric: true, text: '£0.00' }
          }
        )
      end
    end

    context 'when multiple work item of diffent types exists' do
      let(:work_items) do
        [
          {

            work_type: 'advocacy',
            time_spent_original: 600, time_spent: 480, adjustment_comment: 'Foo',
          },
          {
            work_type: 'preparation',
            time_spent_original: 660, time_spent: 540, adjustment_comment: 'Foo',
          }
        ]
      end

      it 'sums them all together in profit costs' do
        expect(subject.table_fields[0]).to eq(
          {
            allowed_gross_cost: { numeric: true, text: '£992.71' },
            allowed_net_cost: { numeric: true, text: '£992.71' }, allowed_vat: { numeric: true, text: '£0.00' },
            gross_cost: { numeric: true, text: '£1,227.85' }, name: { numeric: false, text: 'Profit costs', width: nil },
            net_cost: { numeric: true, text: '£1,227.85' }, vat: { numeric: true, text: '£0.00' }
          }
        )
      end
    end

    context 'when waiting and travel work items exist' do
      let(:work_items) do
        [
          {
            work_type: 'travel',
            time_spent_original: 600, time_spent: 480, adjustment_comment: 'Foo',
          },
          {
            work_type: 'waiting',
            time_spent_original: 600, time_spent: 480, adjustment_comment: 'Foo',
          },
          {
            work_type: 'preparation',
            time_spent_original: 660, time_spent: 540, adjustment_comment: 'Foo',
          }
        ]
      end

      it 'they are returned' do
        expect(subject.table_fields[3]).to eq(
          {
            allowed_gross_cost: { numeric: true, text: '£220.80' }, allowed_net_cost: { numeric: true, text: '£220.80' },
            allowed_vat: { numeric: true, text: '£0.00' }, gross_cost: { numeric: true, text: '£276.00' },
            name: { numeric: false, text: 'Waiting', width: nil }, net_cost: { numeric: true, text: '£276.00' },
            vat: { numeric: true, text: '£0.00' }
          }
        )
        expect(subject.table_fields[2]).to eq(
          {
            allowed_gross_cost: { numeric: true, text: '£220.80' }, allowed_net_cost: { numeric: true, text: '£220.80' },
            allowed_vat: { numeric: true, text: '£0.00' }, gross_cost: { numeric: true, text: '£276.00' },
            name: { numeric: false, text: 'Travel', width: nil }, net_cost: { numeric: true, text: '£276.00' },
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
            time_spent_original: 600, time_spent: 480, adjustment_comment: 'Foo',
          },
          {
            work_type: 'advocacy',
            time_spent_original: 660, time_spent: 540, adjustment_comment: 'Foo',
          }
        ]
      end

      it 'includes a summed table field row' do
        expect(subject.table_fields[0]).to eq(
          {
            allowed_gross_cost: { numeric: true, text: '£1,112.14' },
            allowed_net_cost: { numeric: true, text: '£1,112.14' }, allowed_vat: { numeric: true, text: '£0.00' },
            gross_cost: { numeric: true, text: '£1,373.82' }, name: { numeric: false, text: 'Profit costs', width: nil },
            net_cost: { numeric: true, text: '£1,373.82' }, vat: { numeric: true, text: '£0.00' }
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
            allowed_gross_cost: { numeric: true, text: '£523.36' },
            allowed_net_cost: { numeric: true, text: '£523.36' },
            allowed_vat: { numeric: true, text: '£0.00' },
            gross_cost: { numeric: true, text: '£0.00' },
            name: { numeric: false, text: 'Profit costs', width: nil },
            net_cost: { numeric: true, text: '£0.00' },
            vat: { numeric: true, text: '£0.00' }
          }
        )
      end

      it 'includes shows something sensible for waiting' do
        name_html = '<span title="One or more of these items were adjusted to be a different work item type.">' \
                    'Waiting</span> <sup><a href="#fn*">[*]</a></sup>'
        expect(subject.table_fields).to include(
          { allowed_gross_cost: { numeric: true, text: '£0.00' },
          allowed_net_cost: { numeric: true, text: '£0.00' },
          allowed_vat: { numeric: true, text: '£0.00' },
          gross_cost: { numeric: true, text: '£220.80' },
          name:            { numeric: false,
            text: name_html },
          net_cost: { numeric: true, text: '£220.80' },
          vat: { numeric: true, text: '£0.00' } }
        )
      end
    end

    context 'when disbursements exists - with adjustments' do
      let(:disbursements) do
        [
          {
            total_cost_without_vat: 0.0, total_cost_without_vat_original: 60.0,
            apply_vat: 'false', apply_vat_original: 'true', disbursement_type: 'other'
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
          { 'type' => 'letters', 'count' => 10 },
          { 'type' => 'calls', 'count' => 5 }
        ]
      end

      it 'sums them into profit costs' do
        expect(subject.table_fields[0]).to eq(
          {
            allowed_gross_cost: '',
            allowed_net_cost: '',
            allowed_vat: '',
            gross_cost: { numeric: true, text: '£61.35' },
            name: { numeric: false, text: 'Profit costs', width: nil },
            net_cost: { numeric: true, text: '£61.35' },
            vat: { numeric: true, text: '£0.00' }
          }
        )
      end
    end

    context 'when a youth court fee has been added' do
      before do
        submission.data.merge(data)
        subject { described_class.new(submission:) }
      end

      let(:rep_order_date) { Date.new(2024, 12, 6) }
      let(:include_youth_court_fee) { true }
      let(:include_youth_court_fee_original) { nil }

      it 'adds the fee to the profit costs' do
        expect(subject.table_fields[0]).to eq(
          {
            allowed_gross_cost: '',
            allowed_net_cost: '',
            allowed_vat: '',
            gross_cost: { numeric: true, text: '£598.59' },
            name: { numeric: false, text: 'Profit costs', width: nil },
            net_cost: { numeric: true, text: '£598.59' },
            vat: { numeric: true, text: '£0.00' }
          }
        )
      end
    end

    context 'when a youth court fee has been added and assessed' do
      before do
        submission.data.merge(data)
      end

      let(:rep_order_date) { Date.new(2024, 12, 6) }
      let(:include_youth_court_fee) { false }
      let(:include_youth_court_fee_original) { true }

      it 'adds the fee to the profit costs' do
        expect(subject.table_fields[0]).to eq(
          {
            allowed_gross_cost: '',
            allowed_net_cost: '',
            allowed_vat: '',
            gross_cost: { numeric: true, text: '£598.59' },
            name: { numeric: false, text: 'Profit costs', width: nil },
            net_cost: { numeric: true, text: '£598.59' },
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
          gross_cost: { numeric: true, text: '£5,724.25' },
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
            time_spent_original: 600, time_spent: 480, adjustment_comment: 'Foo',
          }
        ]
      end

      it 'returns the summed time and cost' do
        expect(subject.formatted_summed_fields).to eq(
          {
            allowed_gross_cost: { numeric: true, text: '£623.36' }, allowed_net_cost: { numeric: true, text: '£623.36' },
            allowed_vat: { numeric: true, text: '£0.00' }, gross_cost: { numeric: true, text: '£754.20' },
            name: { numeric: false, text: 'Total', width: nil }, net_cost: { numeric: true, text: '£754.20' },
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
            time_spent: 480,
          }
        ]
      end

      it 'returns the summed time and cost' do
        expect(subject.formatted_summed_fields).to eq(
          {
            allowed_gross_cost: '', allowed_net_cost: '', allowed_vat: '', gross_cost: { numeric: true, text: '£623.36' },
            name: { numeric: false, text: 'Total', width: nil }, net_cost: { numeric: true, text: '£623.36' },
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
            time_spent: 480,
          }
        ]
      end

      it 'returns the summed time and cost' do
        expect(subject.formatted_summed_fields).to eq(
          {
            allowed_gross_cost: '', allowed_net_cost: '', allowed_vat: '', gross_cost: { numeric: true, text: '£728.03' },
            name: { numeric: false, text: 'Total', width: nil }, net_cost: { numeric: true, text: '£623.36' },
            vat: { numeric: true, text: '£104.67' }
          }
        )
      end
    end

    context 'when multiple work item of diffent types exists' do
      let(:work_items) do
        [
          {
            work_type: 'advocacy',
            time_spent_original: 600, time_spent: 480, adjustment_comment: 'Foo',
          },
          {
            work_type: 'travel',
            time_spent_original: 600, time_spent: 480, adjustment_comment: 'Foo',
          }
        ]
      end

      it 'returns the summed cost' do
        expect(subject.formatted_summed_fields).to eq(
          {
            allowed_gross_cost: { numeric: true, text: '£844.16' }, allowed_net_cost: { numeric: true, text: '£844.16' },
            allowed_vat: { numeric: true, text: '£0.00' }, gross_cost: { numeric: true, text: '£1,030.20' },
            name: { numeric: false, text: 'Total', width: nil }, net_cost: { numeric: true, text: '£1,030.20' },
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
            time_spent_original: 600, time_spent: 480, adjustment_comment: 'Foo',
          },
          {
            work_type: 'advocacy',
             time_spent_original: 600, time_spent: 480, adjustment_comment: 'Foo',
          }
        ]
      end

      it 'returns the summed cost' do
        expect(subject.formatted_summed_fields).to eq(
          {
            allowed_gross_cost: { numeric: true, text: '£1,146.72' }, allowed_net_cost: { numeric: true, text: '£1,146.72' },
            allowed_vat: { numeric: true, text: '£0.00' }, gross_cost: { numeric: true, text: '£1,408.40' },
            name: { numeric: false, text: 'Total', width: nil }, net_cost: { numeric: true, text: '£1,408.40' },
            vat: { numeric: true, text: '£0.00' }
          }
        )
      end
    end

    context 'when letters and calls exist' do
      let(:letters_and_calls) do
        [
          { 'type' => 'letters', 'count' => 10 },
          { 'type' => 'calls', 'count' => 5 }
        ]
      end

      it 'returns the summed cost' do
        expect(subject.formatted_summed_fields).to eq(
          {
            allowed_gross_cost: '',
            allowed_net_cost: '',
            allowed_vat: '',
            gross_cost: { numeric: true, text: '£161.35' },
            name: { numeric: false, text: 'Total', width: nil },
            net_cost: { numeric: true, text: '£161.35' },
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
            time_spent: 480,
          }
        ]
      end
      let(:state) { 'rejected' }

      it 'returns the summed time and cost' do
        expect(subject.formatted_summed_fields).to eq(
          {
            allowed_gross_cost: { numeric: true, text: '£0.00' }, allowed_net_cost: { numeric: true, text: '£0.00' },
            allowed_vat: { numeric: true, text: '£0.00' }, gross_cost: { numeric: true, text: '£623.36' },
            name: { numeric: false, text: 'Total', width: nil }, net_cost: { numeric: true, text: '£623.36' },
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
            time_spent: 480,
          }
        ]
      end
      let(:state) { 'granted' }

      it 'returns the summed time and cost' do
        expect(subject.formatted_summed_fields).to eq(
          {
            allowed_gross_cost: '', allowed_net_cost: '', allowed_vat: '', gross_cost: { numeric: true, text: '£623.36' },
            name: { numeric: false, text: 'Total', width: nil }, net_cost: { numeric: true, text: '£623.36' },
            vat: { numeric: true, text: '£0.00' }
          }
        )
      end
    end
  end
end
