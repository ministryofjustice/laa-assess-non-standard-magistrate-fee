require 'rails_helper'

RSpec.describe PriorAuthority::V1::Quote do
  describe '#formatted_travel_cost_per_unit' do
    subject(:formatted_travel_cost_per_unit) do
      described_class.new(travel_cost_per_hour: 10.1).formatted_travel_cost_per_unit
    end

    it 'returns the humanized currency value sentence' do
      expect(formatted_travel_cost_per_unit).to eq '£10.10 per hour'
    end
  end

  describe '#formatted_base_cost_per_unit' do
    subject(:formatted_base_cost_per_unit) do
      described_class.new(cost_type:, **cost_attributes).formatted_base_cost_per_unit
    end

    context 'with cost type per_hour' do
      let(:cost_type) { 'per_hour' }
      let(:cost_attributes) { { cost_per_hour: 53.3 } }

      it 'returns the humanized currency value sentence' do
        expect(formatted_base_cost_per_unit).to eq '£53.30 per hour'
      end
    end

    context 'with cost type per_item' do
      let(:cost_type) { 'per_item' }
      let(:cost_attributes) { { cost_per_item: 33.2 } }

      it 'returns the humanized currency value sentence' do
        expect(formatted_base_cost_per_unit).to eq '£33.20 per item'
      end
    end
  end
end
