require 'rails_helper'

RSpec.describe Nsm::V1::WorkItemSummary do
  subject { described_class.build(:work_item_summary, claim) }

  let(:claim) { build(:claim, work_items:) }

  describe '#header' do
    let(:work_items) { [] }

    it 'renders the translations' do
      expect(subject.header).to eq(
        [
          { numeric: false, text: 'Item' },
          { numeric: true, text: 'Time claimed' },
          { numeric: true, text: 'Net cost claimed' },
          { numeric: true, text: 'Time allowed' },
          { numeric: true, text: 'Net cost allowed' }
        ]
      )
    end
  end

  describe 'footer' do
    let(:work_items) do
      [{ 'work_type' => 'travel',
          'time_spent' => 20, 'vat_rate' => 0.2, 'pricing' => 300.0 },
       { 'work_type' => 'waiting',
         'time_spent' => 30, 'vat_rate' => 0.2, 'pricing' => 200.0 }]
    end

    it 'renders a summary row' do
      expect(subject.footer).to eq(
        [
          { numeric: false, text: 'Total' },
          { numeric: true, text: '' },
          { numeric: true, text: '<span class="govuk-visually-hidden">Sum of net cost claimed: </span>£200.00' },
          '', ''
        ]
      )
    end
  end

  describe '#table_fields' do
    context 'when a single work item exists' do
      let(:work_items) do
        [{ 'work_type' => 'travel',
           'time_spent' => 20, 'vat_rate' => 0.2, 'pricing' => 300.0 }]
      end

      it 'includes the summed table field row' do
        expect(subject.table_fields).to include(
          [
            'Travel',
            {
              numeric: true,
              text: '0<span class="govuk-visually-hidden"> hours</span>:20<span class="govuk-visually-hidden"> minutes</span>'
            },
            { numeric: true, text: '£100.00' },
            '', ''
          ]
        )
      end
    end

    context 'when a work item has an adjustments' do
      let(:work_items) do
        [{ 'work_type' => 'travel', 'adjustment_comment' => 'Foo',
           'time_spent_original' => 40, 'time_spent' => 20, 'vat_rate' => 0.2, 'pricing' => 300.0 }]
      end

      it 'includes the summed table field row' do
        expect(subject.table_fields).to include(
          [
            'Travel',
            {
              numeric: true,
              text: '0<span class="govuk-visually-hidden"> hours</span>:40<span class="govuk-visually-hidden"> minutes</span>'
            },
            { numeric: true, text: '£200.00' },
            {
              numeric: true,
              text: '0<span class="govuk-visually-hidden"> hours</span>:20<span class="govuk-visually-hidden"> minutes</span>'
            },
            { numeric: true, text: '£100.00' }
          ]
        )
      end
    end

    context 'when waiting and travel work items do not exist' do
      let(:work_items) do
        [{ 'work_type' => 'preparation',
           'time_spent' => 30, 'vat_rate' => 0.2, 'pricing' => 300.0 }]
      end

      it 'still returns rows for travel and waiting' do
        expect(subject.table_fields.pluck(0)).to include('Travel')
        expect(subject.table_fields.pluck(0)).to include('Waiting')
      end
    end

    context 'when multiple work item of the same types exists' do
      let(:work_items) do
        [{ 'work_type' => 'travel',
           'time_spent' => 20, 'vat_rate' => 0.2, 'pricing' => 150.0 },
         { 'work_type' => 'travel',
           'time_spent' => 30, 'vat_rate' => 0.2, 'pricing' => 300.0 }]
      end

      it 'includes a summed table field row' do
        expect(subject.table_fields).to include(
          [
            'Travel',
            {
              numeric: true,
              text: '0<span class="govuk-visually-hidden"> hours</span>:50<span class="govuk-visually-hidden"> minutes</span>'
            },
            { numeric: true, text: '£200.00' },
            '', ''
          ]
        )
      end
    end
  end
end
