require 'rails_helper'

RSpec.describe PriorAuthority::V1::AdditionalCost do
  describe '#unit_description' do
    it 'translates a period into something sensible' do
      cost = described_class.new(unit_type: 'per_hour', period: 180)
      expect(cost.unit_description).to eq('3 Hrs 0 Mins')
    end

    it 'translates an item into something sensible' do
      cost = described_class.new(unit_type: 'per_item', items: 1)
      expect(cost.unit_description).to eq('1 item')
    end
  end

  describe '#cost_per_unit' do
    it 'translates a period into something sensible' do
      cost = described_class.new(unit_type: 'per_hour', cost_per_hour: 50.3)
      expect(cost.cost_per_unit).to eq('£50.30')
    end

    it 'translates an item into something sensible' do
      cost = described_class.new(unit_type: 'per_item', cost_per_item: 1)
      expect(cost.cost_per_unit).to eq('£1.00')
    end
  end
end
