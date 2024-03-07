require 'rails_helper'

RSpec.describe PriorAuthority::V1::Quote do
  describe '#base_cost' do
    subject(:base_cost) { described_class.new(attributes).base_cost }

    context 'when cost is per item' do
      let(:attributes) { { cost_type: 'per_item', items: 3, cost_per_item: '33.5' } }

      it 'returns total item cost' do
        expect(subject).to eq 100.5
      end
    end

    context 'when cost is per hour' do
      let(:attributes) { { cost_type: 'per_hour', period: 90, cost_per_hour: '33.5' } }

      it 'returns total hour-based' do
        expect(subject).to eq 50.25
      end
    end
  end

  describe '#base_units' do
    subject(:base_units) { described_class.new(attributes).base_units }

    context 'when cost is per item' do
      let(:attributes) { { cost_type: 'per_item', items: 3, item_type: 'minute' } }

      it 'returns formatted number of items' do
        expect(subject).to eq '3 minutes'
      end
    end

    context 'when cost is per hour' do
      let(:attributes) { { cost_type: 'per_hour', period: 65 } }

      it 'returns formatted time' do
        expect(subject).to eq '1 hour 5 minutes'
      end
    end
  end

  describe '#travel_costs' do
    subject(:travel_costs) { described_class.new(attributes).travel_costs }

    context 'when there are travel_costs' do
      let(:attributes) { { travel_time: 180, travel_cost_per_hour: '40' } }

      it 'returns the hour-based cost' do
        expect(subject).to eq 120
      end
    end

    context 'when there are no travel_costs' do
      let(:attributes) { {} }

      it 'returns zero' do
        expect(subject).to eq 0
      end
    end
  end

  describe '#total_additional_costs' do
    subject(:total_additional_costs) { described_class.new(attributes).total_additional_costs }

    context 'when there are additional cost objects' do
      let(:attributes) { { additional_cost_json: [item_based_additional_cost, time_based_additional_cost] } }
      let(:item_based_additional_cost) { { unit_type: 'per_item', items: 1, cost_per_item: 10 } }
      let(:time_based_additional_cost) { { unit_type: 'per_hour', period: 30, cost_per_hour: 30 } }

      it 'returns the sum of additional cost totals' do
        expect(subject).to eq 25
      end
    end

    context 'when there is an additional cost total' do
      let(:attributes) { { additional_cost_total: '12.3' } }

      it 'returns the total' do
        expect(subject).to eq 12.3
      end
    end

    context 'when there are no additional costs' do
      let(:attributes) { {} }

      it 'returns zero' do
        expect(subject).to eq 0
      end
    end
  end

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

      context 'with unusual item type' do
        let(:cost_attributes) { { cost_per_item: 33.2, item_type: 'page' } }

        it 'returns the humanized currency value sentence' do
          expect(formatted_base_cost_per_unit).to eq '£33.20 per page'
        end
      end
    end
  end
end
