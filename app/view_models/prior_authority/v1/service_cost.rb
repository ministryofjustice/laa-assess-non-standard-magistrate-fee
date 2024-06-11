module PriorAuthority
  module V1
    class ServiceCost < BaseWithAdjustments
      LINKED_TYPE = 'quotes'.freeze

      attribute :id, :string
      attribute :cost_type, :string
      attribute :item_type, :string, default: 'item'
      attribute :cost_multiplier, :decimal, precision: 10, scale: 5

      adjustable_attribute :cost_per_hour, :decimal, precision: 10, scale: 2
      adjustable_attribute :cost_per_item, :decimal, precision: 10, scale: 2
      adjustable_attribute :items, :integer
      adjustable_attribute :period, :time_period

      def form_attributes
        attributes.slice('id', 'cost_type', 'period', 'cost_per_hour', 'items', 'item_type', 'cost_per_item')
      end
    end
  end
end
