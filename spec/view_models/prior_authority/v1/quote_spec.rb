require 'rails_helper'

RSpec.describe PriorAuthority::V1::Quote do
  describe '#base_cost' do
    subject(:base_cost) { described_class.new(attributes).base_cost }

    context 'when cost is per item and default cost multiplier' do
      let(:attributes) { { cost_type: 'per_item', items: 3, cost_per_item: '33.5' } }

      it 'returns total item cost' do
        expect(subject).to eq 100.5
      end
    end

    context 'when cost is per item and custom cost multiplier' do
      let(:attributes) { { cost_type: 'per_item', items: 300, cost_per_item: '33.5', cost_multiplier: 0.001 } }

      it 'returns total item cost' do
        expect(subject).to eq 10.05
      end
    end

    context 'when cost is per hour' do
      let(:attributes) { { cost_type: 'per_hour', period: 90, cost_per_hour: '33.5' } }

      it 'returns total hour-based' do
        expect(subject).to eq 50.25
      end
    end

    context 'when cost type not recognised' do
      let(:attributes) { { cost_type: 'random', period: 90, cost_per_hour: '33.5' } }

      it 'returns nil' do
        expect(subject).to be_nil
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

  context 'with service costs' do
    describe '#requested_humanized_units' do
      subject(:requested_humanized_units) do
        described_class.new(attributes).requested_humanized_units
      end

      context 'with adusted number of items' do
        let(:attributes) do
          {
            cost_type: 'per_item',
            item_type: 'word',
            items: 1000,
            items_original: 900
          }
        end

        it 'returns formatted original number of items' do
          expect(requested_humanized_units).to eql '900 words'
        end
      end

      context 'with unadusted number of items' do
        let(:attributes) do
          {
            cost_type: 'per_item',
            item_type: 'minute',
            items: 120,
          }
        end

        it 'returns formatted number of items' do
          expect(requested_humanized_units).to eql '120 minutes'
        end
      end

      context 'with adjusted time period' do
        let(:attributes) do
          {
            cost_type: 'per_hour',
            item_type: 'item',
            period: 90,
            period_original: 120
          }
        end

        it 'returns formatted original time period' do
          expect(requested_humanized_units).to eql '2 hours 0 minutes'
        end
      end

      context 'with unadjusted time period' do
        let(:attributes) do
          {
            cost_type: 'per_hour',
            item_type: 'item',
            period: 90,
          }
        end

        it 'returns formatted original time period' do
          expect(requested_humanized_units).to eql '1 hour 30 minutes'
        end
      end
    end

    describe '#requested_humanized_cost_per_unit' do
      subject(:requested_humanized_cost_per_unit) do
        described_class.new(attributes).requested_humanized_cost_per_unit
      end

      context 'with adusted cost per item (word)' do
        let(:attributes) do
          {
            cost_type: 'per_item',
            item_type: 'word',
            cost_item_type: 'word',
            items: 1000,
            cost_per_item: '0.10',
            cost_per_item_original: '0.20'
          }
        end

        it 'returns formatted original cost per item' do
          expect(requested_humanized_cost_per_unit).to eql '£0.20 per word'
        end
      end

      context 'with unadusted cost per item (word)' do
        let(:attributes) do
          {
            cost_type: 'per_item',
            item_type: 'word',
            cost_item_type: 'word',
            items: 1000,
            cost_per_item: '0.20',
          }
        end

        it 'returns formatted cost per item' do
          expect(requested_humanized_cost_per_unit).to eql '£0.20 per word'
        end
      end

      context 'with adjusted cost per hour AND adjusted period' do
        let(:attributes) do
          {
            cost_type: 'per_hour',
            cost_per_hour: '120.00',
            cost_per_hour_original: '150.00',
            period: 90,
            period_original: 180,
          }
        end

        it 'returns formatted original cost per hour' do
          expect(requested_humanized_cost_per_unit).to eql '£150.00 per hour'
        end
      end

      context 'with adjusted cost per hour BUT unadjusted period' do
        let(:attributes) do
          {
            cost_type: 'per_hour',
            cost_per_hour: '120.00',
            cost_per_hour_original: '150.00',
          }
        end

        it 'returns formatted original cost per hour' do
          expect(requested_humanized_cost_per_unit).to eql '£150.00 per hour'
        end
      end

      context 'with unadjusted cost per hour BUT adjusted period' do
        let(:attributes) do
          {
            cost_type: 'per_hour',
            cost_per_hour: '120.00',
            period_original: 90,
          }
        end

        it 'returns formatted cost per hour' do
          expect(requested_humanized_cost_per_unit).to eql '£120.00 per hour'
        end
      end
    end

    describe '#requested_formatted_service_cost_total' do
      subject(:requested_formatted_service_cost_total) do
        described_class.new(attributes).requested_formatted_service_cost_total
      end

      context 'with hourly adjustments' do
        let(:attributes) do
          {
            cost_type: 'per_hour',
            cost_per_hour: '120.00',
            period: 120,
            period_original: 90,
          }
        end

        it 'returns formatted original total' do
          expect(requested_formatted_service_cost_total).to eql '£180.00'
        end
      end

      context 'without hourly adjustments' do
        let(:attributes) do
          {
            cost_type: 'per_hour',
            cost_per_hour: '120.00',
            period: 120,
          }
        end

        it 'returns formatted total' do
          expect(requested_formatted_service_cost_total).to eql '£240.00'
        end

        context 'with item adjustments' do
          let(:attributes) do
            {
              cost_type: 'per_item',
              item_type: 'page',
              cost_per_item: '50.00',
              items: 9,
              items_original: 10,
            }
          end

          it 'returns formatted original total' do
            expect(requested_formatted_service_cost_total).to eql '£500.00'
          end

          context 'without item adjustments' do
            let(:attributes) do
              {
                cost_type: 'per_item',
                item_type: 'page',
                cost_per_item: '50.00',
                items: 11,
              }
            end

            it 'returns formatted original total' do
              expect(requested_formatted_service_cost_total).to eql '£550.00'
            end
          end
        end
      end
    end

    describe '#adjusted_humanized_units' do
      subject(:adjusted_humanized_units) do
        described_class.new(attributes).adjusted_humanized_units
      end

      context 'with adjusted items' do
        let(:attributes) do
          {
            cost_type: 'per_item',
            cost_item_type: 'per_item',
            item_type: 'word',
            items: 1000,
            items_original: 900
          }
        end

        it 'returns formatted adjusted number of items' do
          expect(adjusted_humanized_units).to eql '1000 words'
        end
      end

      context 'with adjusted item cost' do
        let(:attributes) do
          {
            cost_type: 'per_item',
            cost_item_type: 'per_item',
            item_type: 'word',
            items: 1000,
            cost_per_item_original: '1.00'
          }
        end

        it 'returns formatted adjusted number of items' do
          expect(adjusted_humanized_units).to eql '1000 words'
        end
      end

      context 'without any item unadustment' do
        let(:attributes) do
          {
            cost_type: 'per_item',
            cost_item_type: 'per_item',
            item_type: 'minute',
            items: 120,
            cost_per_item: '5.00'
          }
        end

        it 'returns formatted number of items' do
          expect(adjusted_humanized_units).to be_nil
        end
      end

      context 'with adjusted time period' do
        let(:attributes) do
          {
            cost_type: 'per_hour',
            period: 90,
            period_original: 120
          }
        end

        it 'returns formatted original time period' do
          expect(adjusted_humanized_units).to eql '1 hour 30 minutes'
        end
      end

      context 'with adjusted cost per hour' do
        let(:attributes) do
          {
            cost_type: 'per_hour',
            period: 90,
            cost_per_hour_original: 120
          }
        end

        it 'returns formatted original time period' do
          expect(adjusted_humanized_units).to eql '1 hour 30 minutes'
        end
      end

      context 'without time period or cost unadustment' do
        let(:attributes) do
          {
            cost_type: 'per_hour',
            period: 90,
            cost_per_hour: '120.00'
          }
        end

        it 'returns formatted time period' do
          expect(adjusted_humanized_units).to be_nil
        end
      end
    end

    describe '#adjusted_humanized_cost_per_unit' do
      subject(:adjusted_humanized_cost_per_unit) do
        described_class.new(attributes).adjusted_humanized_cost_per_unit
      end

      context 'with adjusted cost per item' do
        let(:attributes) do
          {
            cost_type: 'per_item',
            cost_item_type: 'word',
            item_type: 'word',
            items: 1000,
            cost_per_item: '0.50',
            cost_per_item_original: '1.00'
          }
        end

        it 'returns formatted adjusted cost per item (word)' do
          expect(adjusted_humanized_cost_per_unit).to eql '£0.50 per word'
        end
      end

      context 'with unadjusted item cost BUT adjusted item count' do
        let(:attributes) do
          {
            cost_type: 'per_item',
            cost_item_type: 'word',
            item_type: 'word',
            items: 1000,
            items_original: 1000,
            cost_per_item: '0.50'
          }
        end

        it 'returns formatted unadjusted cost per item (word)' do
          expect(adjusted_humanized_cost_per_unit).to eql '£0.50 per word'
        end
      end

      context 'without any item adustment' do
        let(:attributes) do
          {
            cost_type: 'per_item',
            item_type: 'word',
            items: 1000,
            cost_per_item: '0.50'
          }
        end

        it 'returns nil' do
          expect(adjusted_humanized_cost_per_unit).to be_nil
        end
      end

      context 'with adjusted time period BUT unadjusted cost per hour' do
        let(:attributes) do
          {
            cost_type: 'per_hour',
            period: 90,
            period_original: 120,
            cost_per_hour: '111.00',
          }
        end

        it 'returns formatted cost per hour' do
          expect(adjusted_humanized_cost_per_unit).to eql '£111.00 per hour'
        end
      end

      context 'with adjusted cost per hour BUT unadjusted time period' do
        let(:attributes) do
          {
            cost_type: 'per_hour',
            period: 90,
            cost_per_hour: '100.00',
            cost_per_hour_original: '111.00',
          }
        end

        it 'returns formatted cost per hour' do
          expect(adjusted_humanized_cost_per_unit).to eql '£100.00 per hour'
        end
      end

      context 'without time period or cost adustment' do
        let(:attributes) do
          {
            cost_type: 'per_hour',
            period: 90,
            cost_per_hour: '120.00'
          }
        end

        it 'returns formatted time period' do
          expect(adjusted_humanized_cost_per_unit).to be_nil
        end
      end
    end

    describe '#adjusted_formatted_service_cost_total' do
      subject(:adjusted_formatted_service_cost_total) do
        described_class.new(attributes).adjusted_formatted_service_cost_total
      end

      context 'with hourly adjustments' do
        let(:attributes) do
          {
            cost_type: 'per_hour',
            cost_per_hour: '120.00',
            period: 120,
            period_original: 90,
          }
        end

        it 'returns formatted adjusted total' do
          expect(adjusted_formatted_service_cost_total).to eql '£240.00'
        end
      end

      context 'without hourly adjustments' do
        let(:attributes) do
          {
            cost_type: 'per_hour',
            cost_per_hour: '120.00',
            period: 120,
          }
        end

        it 'returns nil' do
          expect(adjusted_formatted_service_cost_total).to be_nil
        end

        context 'with item adjustments' do
          let(:attributes) do
            {
              cost_type: 'per_item',
              item_type: 'page',
              cost_per_item: '50.00',
              items: 9,
              items_original: 10,
            }
          end

          it 'returns formatted adjusted total' do
            expect(adjusted_formatted_service_cost_total).to eql '£450.00'
          end

          context 'without item adjustments' do
            let(:attributes) do
              {
                cost_type: 'per_item',
                item_type: 'page',
                cost_per_item: '50.00',
                items: 11,
              }
            end

            it 'returns formatted original total' do
              expect(adjusted_formatted_service_cost_total).to be_nil
            end
          end
        end
      end
    end
  end

  context 'with travel costs' do
    describe '#requested_travel_units' do
      subject(:requested_travel_units) do
        described_class.new(attributes).requested_travel_units
      end

      context 'with adjusted travel time' do
        let(:attributes) { { travel_time: 90, travel_time_original: 120 } }

        it 'returns formatted original travel time' do
          expect(requested_travel_units).to eql '2 hours 0 minutes'
        end
      end

      context 'with unadjusted travel time' do
        let(:attributes) { { travel_time: 90 } }

        it 'returns formatted travel time' do
          expect(requested_travel_units).to eql '1 hour 30 minutes'
        end
      end

      context 'with nil travel time' do
        let(:attributes) { { travel_time: nil } }

        it 'returns nil' do
          expect(requested_travel_units).to be_nil
        end
      end
    end

    describe '#requested_formatted_travel_cost_per_hour' do
      subject(:requested_formatted_travel_cost_per_hour) do
        described_class.new(attributes).requested_formatted_travel_cost_per_hour
      end

      context 'with adjusted travel cost per hour' do
        let(:attributes) { { travel_cost_per_hour: '25.00', travel_cost_per_hour_original: '30.00' } }

        it 'returns formatted original travel cost per hour' do
          expect(requested_formatted_travel_cost_per_hour).to eql '£30.00 per hour'
        end
      end

      context 'with unadjusted travel cost per hour' do
        let(:attributes) { { travel_cost_per_hour: '28:00' } }

        it 'returns formatted travel cost per hour' do
          expect(requested_formatted_travel_cost_per_hour).to eql '£28.00 per hour'
        end
      end

      context 'with nil travel cost per hour' do
        let(:attributes) { { travel_cost_per_hour: nil } }

        it 'returns nil' do
          expect(requested_formatted_travel_cost_per_hour).to be_nil
        end
      end
    end

    describe '#requested_formatted_travel_cost' do
      subject(:requested_formatted_travel_cost) do
        described_class.new(attributes).requested_formatted_travel_cost
      end

      context 'with adjusted travel cost' do
        let(:attributes) do
          {
            travel_time: 90,
            travel_time_original: 120,
            travel_cost_per_hour: '25.00',
            travel_cost_per_hour_original: '30.00',
          }
        end

        it 'returns formatted original travel cost' do
          expect(requested_formatted_travel_cost).to eql '£60.00'
        end
      end

      context 'with unadjusted travel costs' do
        let(:attributes) do
          {
            travel_time: 90,
            travel_cost_per_hour: '25.00',
          }
        end

        it 'returns formatted travel cost' do
          expect(requested_formatted_travel_cost).to eql '£37.50'
        end
      end

      context 'with nil travel time' do
        let(:attributes) do
          {
            travel_time: nil,
            travel_cost_per_hour: '25.00',
          }
        end

        it 'returns nil' do
          expect(requested_formatted_travel_cost).to be_nil
        end
      end

      context 'with nil travel cost per hour' do
        let(:attributes) do
          {
            travel_time: 90,
            travel_cost_per_hour: nil,
          }
        end

        it 'returns nil' do
          expect(requested_formatted_travel_cost).to be_nil
        end
      end
    end

    describe '#adjusted_travel_units' do
      subject(:adjusted_travel_units) do
        described_class.new(attributes).adjusted_travel_units
      end

      context 'with adjusted travel time' do
        let(:attributes) { { travel_time: 90, travel_time_original: 120 } }

        it 'returns formatted adjusted travel time' do
          expect(adjusted_travel_units).to eql '1 hour 30 minutes'
        end
      end

      context 'with unadjusted travel time' do
        let(:attributes) { { travel_time: 90 } }

        it 'returns nil' do
          expect(adjusted_travel_units).to be_nil
        end
      end

      context 'with nil travel time' do
        let(:attributes) { { travel_time: nil } }

        it 'returns nil' do
          expect(adjusted_travel_units).to be_nil
        end
      end
    end

    describe '#adjusted_formatted_travel_cost_per_hour' do
      subject(:adjusted_formatted_travel_cost_per_hour) do
        described_class.new(attributes).adjusted_formatted_travel_cost_per_hour
      end

      context 'with adjusted travel cost per hour' do
        let(:attributes) { { travel_cost_per_hour: '25.00', travel_cost_per_hour_original: '30.00' } }

        it 'returns formatted adjusted travel cost per hour' do
          expect(adjusted_formatted_travel_cost_per_hour).to eql '£25.00 per hour'
        end
      end

      context 'with unadjusted travel cost per hour' do
        let(:attributes) { { travel_cost_per_hour: '25.00' } }

        it 'returns nil' do
          expect(adjusted_formatted_travel_cost_per_hour).to be_nil
        end
      end

      context 'with unadjusted travel cost per hour BUT adjusted travel time' do
        let(:attributes) { { travel_cost_per_hour: '25.00', travel_time_original: 90 } }

        it 'returns formatted unadjusted travel cost per hour' do
          expect(adjusted_formatted_travel_cost_per_hour).to eql '£25.00 per hour'
        end
      end

      context 'with nil travel cost per hour' do
        let(:attributes) { { travel_cost_per_hour: nil } }

        it 'returns nil' do
          expect(adjusted_formatted_travel_cost_per_hour).to be_nil
        end
      end
    end

    describe '#adjusted_formatted_travel_cost' do
      subject(:adjusted_formatted_travel_cost) do
        described_class.new(attributes).adjusted_formatted_travel_cost
      end

      context 'with adjusted travel time and travel cost per hour' do
        let(:attributes) do
          {
            travel_time: 90,
            travel_time_original: 120,
            travel_cost_per_hour: '15.00',
            travel_cost_per_hour_original: '30.00'
          }
        end

        it 'returns formatted adjusted travel cost per hour multiplied by hour' do
          expect(adjusted_formatted_travel_cost).to eql '£22.50'
        end
      end

      context 'with unadjusted travel time and travel cost per hour' do
        let(:attributes) do
          {
            travel_time: 120,
            travel_cost_per_hour: '30.00',
          }
        end

        it 'returns ni' do
          expect(adjusted_formatted_travel_cost).to be_nil
        end
      end

      context 'with unadjusted travel cost per hour BUT adjusted travel time' do
        let(:attributes) do
          {
            travel_time: 90,
            travel_time_original: 120,
            travel_cost_per_hour: '30.00',
          }
        end

        it 'returns formatted unadjusted travel cost per hour' do
          expect(adjusted_formatted_travel_cost).to eql '£45.00'
        end
      end

      context 'with unadjusted travel time BUT adjusted travel cost per hour' do
        let(:attributes) do
          {
            travel_time: 90,
            travel_cost_per_hour: '15.00',
            travel_cost_per_hour_original: '30.00'
          }
        end

        it 'returns formatted unadjusted travel cost per hour' do
          expect(adjusted_formatted_travel_cost).to eql '£22.50'
        end
      end

      context 'with nil travel cost per hour' do
        let(:attributes) { { travel_cost_per_hour: nil } }

        it 'returns nil' do
          expect(adjusted_formatted_travel_cost).to be_nil
        end
      end
    end
  end
end
