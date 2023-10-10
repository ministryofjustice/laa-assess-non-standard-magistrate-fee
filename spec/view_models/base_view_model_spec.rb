require 'rails_helper'

RSpec.describe BaseViewModel do
  let(:implementation_class) { V1::ClaimSummary }
  let(:claim) { instance_double(Claim, current_version_record: version) }
  let(:version) { instance_double(Version, json_schema_version: 1, data: data) }

  describe '#build' do
    let(:data) { { 'laa_reference' => 'LA111', 'defendants' => [{ 'some' => 'data' }] } }

    it 'builds the object from the hash of attributes' do
      summary = implementation_class.build(:claim_summary, claim)
      expect(summary).to have_attributes(
        laa_reference: 'LA111',
        defendants: [{ 'some' => 'data' }]
      )
    end

    context 'when using nesting' do
      let(:data) do
        { 'work_items' => [{ 'work_type' => { 'value' => 'first' } }, { 'work_type' => { 'value' => 'second' } }] }
      end

      it 'builds the object from the hash of attributes specified by the nested location' do
        work_item = implementation_class.build(:work_item, claim, 'work_items', 1)
        expect(work_item).to have_attributes(work_type: TranslationObject.new('value' => 'second'))
      end
    end
  end

  describe '#build_all' do
    let(:data) do
      { 'work_items' => [{ 'work_type' => { 'value' => 'first' } }, { 'work_type' => { 'value' => 'second' } }] }
    end

    it 'builds the object from the array of hashes of attributes' do
      work_items = implementation_class.build_all(:work_item, claim, 'work_items')
      expect(work_items.count).to eq(2)
      expect(work_items[0]).to have_attributes(work_type: TranslationObject.new('value' => 'first'))
      expect(work_items[1]).to have_attributes(work_type: TranslationObject.new('value' => 'second'))
    end
  end
end
