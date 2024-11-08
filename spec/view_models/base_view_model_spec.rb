require 'rails_helper'

RSpec.describe BaseViewModel do
  let(:implementation_class) { Nsm::V1::ClaimSummary }
  let(:claim) do
    instance_double(
      Claim,
      json_schema_version: 1,
      data: data,
      attributes: { state: },
      events: event,
      is_a?: true,
      namespace: Nsm
    )
  end
  let(:event) { Event }
  let(:state) { 'granted' }

  describe '#build' do
    context 'for a single object' do
      let(:data) { { 'laa_reference' => 'LA111', 'defendants' => [{ 'some' => 'data' }], 'risk' => 'high' } }

      it 'builds the object from the hash of attributes' do
        summary = described_class.build(:claim_summary, claim)
        expect(summary).to have_attributes(
          laa_reference: 'LA111',
          defendants: [{ 'some' => 'data' }]
        )
      end
    end

    context 'for a nested object' do
      let(:data) do
        { 'work_items' => [{ 'work_type' => { 'value' => 'first' } }, { 'work_type' => { 'value' => 'second' } }] }
      end

      it 'builds the object from the array of hashes of attributes' do
        work_items = described_class.build(:work_item, claim, 'work_items')
        expect(work_items.count).to eq(2)
        expect(work_items[0]).to have_attributes(work_type: TranslationObject.new('first', 'nsm.work_type'))
        expect(work_items[1]).to have_attributes(work_type: TranslationObject.new('second', 'nsm.work_type'))
      end
    end
  end
end
