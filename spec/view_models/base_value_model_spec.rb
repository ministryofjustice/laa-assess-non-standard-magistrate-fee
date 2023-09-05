require 'rails_helper'

RSpec.describe V1::ClaimSummary do
  let(:claim) { instance_double(Claim,  current_version_record: version) }
  let(:version) { instance_double(Version, json_schema_version: 1, data: data) }

  describe '#build' do
    let(:data) { {'laa_reference' => 'LA111', 'defendants' => [{'some' => 'data'}]} }

    it 'builds the object from the hash of attributes' do
      summary = described_class.build(:claim_summary, claim)
      expect(summary).to have_attributes(
        laa_reference: 'LA111',
        defendants: [{'some' => 'data'}]
      )
    end

    context 'when using nesting' do
      let(:data) { {'work_items' => [{'id' => 'first'}, {'id' => 'second'}]} }

      it 'builds the object from the hash of attributes specified by the nested location' do
        work_item = described_class.build(:work_item, claim, 'work_items', 1)
        expect(work_item).to have_attributes(id: 'second')
      end
    end
  end

  describe '#build_all' do
    let(:data) { {'work_items' => [{'id' => 'first'}, {'id' => 'second'}]} }

    it 'builds the object from the array of hashes of attributes' do
      work_items = described_class.build_all(:work_item, claim, 'work_items')
      expect(work_items.count).to eq(2)
      expect(work_items[0]).to have_attributes(id: 'first')
      expect(work_items[1]).to have_attributes(id: 'second')
    end
  end
end