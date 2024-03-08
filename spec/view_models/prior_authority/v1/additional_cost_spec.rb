require 'rails_helper'

RSpec.describe PriorAuthority::V1::AdditionalCost do
  describe '#unit_description' do
    it 'translates a period into something sensible' do
      cost = described_class.new(unit_type: 'per_hour', period: 180)
      expect(cost.unit_description).to eq('3 hours 0 minutes')
    end

    it 'translates an item into something sensible' do
      cost = described_class.new(unit_type: 'per_item', items: 1)
      expect(cost.unit_description).to eq('1 item')
    end
  end

  describe '#unit_label' do
    subject(:unit_label) { described_class.new(unit_type:).unit_label }

    context 'with per_hour' do
      let(:unit_type) { 'per_hour' }

      it { is_expected.to eq('Time') }
    end

    context 'with per_item' do
      let(:unit_type) { 'per_item' }

      it { is_expected.to eq('Item') }
    end

    context 'with nil' do
      let(:unit_type) { nil }

      it { is_expected.to be_nil }
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

  describe '#requested_humanized_units' do
    subject(:requested_humanized_units) do
      described_class.new(attributes).requested_humanized_units
    end

    context 'with adusted number of items' do
      let(:attributes) do
        {
          unit_type: 'per_item',
          items: 1000,
          items_original: 900
        }
      end

      it 'returns formatted original number of items' do
        expect(requested_humanized_units).to eql '900 items'
      end
    end

    context 'with unadusted number of items' do
      let(:attributes) do
        {
          unit_type: 'per_item',
          items: 120,
        }
      end

      it 'returns formatted number of items' do
        expect(requested_humanized_units).to eql '120 items'
      end
    end

    context 'with adjusted time period' do
      let(:attributes) do
        {
          unit_type: 'per_hour',
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
          unit_type: 'per_hour',
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

    context 'with adusted cost per item' do
      let(:attributes) do
        {
          unit_type: 'per_item',
          items: 1000,
          cost_per_item: '0.10',
          cost_per_item_original: '0.20'
        }
      end

      it 'returns formatted original cost per item' do
        expect(requested_humanized_cost_per_unit).to eql '£0.20 per item'
      end
    end

    context 'with unadusted cost per item' do
      let(:attributes) do
        {
          unit_type: 'per_item',
          items: 1000,
          cost_per_item: '0.20',
        }
      end

      it 'returns formatted cost per item' do
        expect(requested_humanized_cost_per_unit).to eql '£0.20 per item'
      end
    end

    context 'with adjusted cost per hour AND adjusted period' do
      let(:attributes) do
        {
          unit_type: 'per_hour',
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
          unit_type: 'per_hour',
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
          unit_type: 'per_hour',
          cost_per_hour: '120.00',
          period_original: 90,
        }
      end

      it 'returns formatted cost per hour' do
        expect(requested_humanized_cost_per_unit).to eql '£120.00 per hour'
      end
    end
  end

  describe '#requested_formatted_cost_total' do
    subject(:requested_formatted_cost_total) do
      described_class.new(attributes).requested_formatted_cost_total
    end

    context 'with hourly adjustments' do
      let(:attributes) do
        {
          unit_type: 'per_hour',
          cost_per_hour: '120.00',
          period: 120,
          period_original: 90,
        }
      end

      it 'returns formatted original total' do
        expect(requested_formatted_cost_total).to eql '£180.00'
      end
    end

    context 'without any adjusted hourly charges' do
      let(:attributes) do
        {
          unit_type: 'per_hour',
          cost_per_hour: '120.00',
          period: 120,
        }
      end

      it 'returns formatted total' do
        expect(requested_formatted_cost_total).to eql '£240.00'
      end

      context 'with item adjustments' do
        let(:attributes) do
          {
            unit_type: 'per_item',
            cost_per_item: '50.00',
            items: 9,
            items_original: 10,
          }
        end

        it 'returns formatted original total' do
          expect(requested_formatted_cost_total).to eql '£500.00'
        end

        context 'without item adjustments' do
          let(:attributes) do
            {
              unit_type: 'per_item',
              cost_per_item: '50.00',
              items: 11,
            }
          end

          it 'returns formatted original total' do
            expect(requested_formatted_cost_total).to eql '£550.00'
          end
        end
      end
    end
  end

  describe '#adjusted_humanized_units' do
    subject(:adjusted_humanized_units) do
      described_class.new(attributes).adjusted_humanized_units
    end

    context 'without adjusted items' do
      let(:attributes) do
        {
          unit_type: 'per_item',
          items: 120,
          cost_per_item: '5.00'
        }
      end

      it 'returns formatted number of items' do
        expect(adjusted_humanized_units).to be_nil
      end
    end

    context 'with adjusted number of items' do
      let(:attributes) do
        {
          unit_type: 'per_item',
          items: 1000,
          items_original: 900
        }
      end

      it 'returns formatted adjusted number of items' do
        expect(adjusted_humanized_units).to eql '1000 items'
      end
    end

    context 'with adjusted item cost' do
      let(:attributes) do
        {
          unit_type: 'per_item',
          items: 1000,
          cost_per_item_original: '1.00'
        }
      end

      it 'returns formatted adjusted number of items' do
        expect(adjusted_humanized_units).to eql '1000 items'
      end
    end

    context 'with adjusted time period' do
      let(:attributes) do
        {
          unit_type: 'per_hour',
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
          unit_type: 'per_hour',
          period: 90,
          cost_per_hour_original: 120
        }
      end

      it 'returns formatted original time period' do
        expect(adjusted_humanized_units).to eql '1 hour 30 minutes'
      end
    end

    context 'without any adjusted hourly charges' do
      let(:attributes) do
        {
          unit_type: 'per_hour',
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
          unit_type: 'per_item',
          items: 1000,
          cost_per_item: '0.50',
          cost_per_item_original: '1.00'
        }
      end

      it 'returns formatted adjusted cost per item' do
        expect(adjusted_humanized_cost_per_unit).to eql '£0.50 per item'
      end
    end

    context 'with unadjusted item cost BUT adjusted item count' do
      let(:attributes) do
        {
          unit_type: 'per_item',
          items: 1000,
          items_original: 1000,
          cost_per_item: '0.50'
        }
      end

      it 'returns formatted unadjusted cost per item' do
        expect(adjusted_humanized_cost_per_unit).to eql '£0.50 per item'
      end
    end

    context 'without any item adustment' do
      let(:attributes) do
        {
          unit_type: 'per_item',
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
          unit_type: 'per_hour',
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
          unit_type: 'per_hour',
          period: 90,
          cost_per_hour: '100.00',
          cost_per_hour_original: '111.00',
        }
      end

      it 'returns formatted cost per hour' do
        expect(adjusted_humanized_cost_per_unit).to eql '£100.00 per hour'
      end
    end

    context 'without any adjusted hourly charges' do
      let(:attributes) do
        {
          unit_type: 'per_hour',
          period: 90,
          cost_per_hour: '120.00'
        }
      end

      it 'returns formatted time period' do
        expect(adjusted_humanized_cost_per_unit).to be_nil
      end
    end
  end

  describe '#adjusted_formatted_cost_total' do
    subject(:adjusted_formatted_cost_total) do
      described_class.new(attributes).adjusted_formatted_cost_total
    end

    context 'with hourly adjustments' do
      let(:attributes) do
        {
          unit_type: 'per_hour',
          cost_per_hour: '120.00',
          period: 120,
          period_original: 90,
        }
      end

      it 'returns formatted adjusted total' do
        expect(adjusted_formatted_cost_total).to eql '£240.00'
      end
    end

    context 'without any adjusted hourly charges' do
      let(:attributes) do
        {
          unit_type: 'per_hour',
          cost_per_hour: '120.00',
          period: 120,
        }
      end

      it 'returns nil' do
        expect(adjusted_formatted_cost_total).to be_nil
      end

      context 'with item adjustments' do
        let(:attributes) do
          {
            unit_type: 'per_item',
            cost_per_item: '50.00',
            items: 9,
            items_original: 10,
          }
        end

        it 'returns formatted adjusted total' do
          expect(adjusted_formatted_cost_total).to eql '£450.00'
        end

        context 'adjusted_formatted_cost_total item adjustments' do
          let(:attributes) do
            {
              unit_type: 'per_item',
              cost_per_item: '50.00',
              items: 11,
            }
          end

          it 'returns formatted original total' do
            expect(adjusted_formatted_cost_total).to be_nil
          end
        end
      end
    end
  end
end
