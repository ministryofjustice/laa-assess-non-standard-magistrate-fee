module PriorAuthority
  module V1
    class ServiceCost < BaseWithAdjustments
      LINKED_TYPE = 'quotes'.freeze

      attribute :id, :string
      attribute :cost_type, :string
      attribute :cost_per_hour, :gbp
      attribute :cost_per_item, :gbp
      attribute :items, :integer
      attribute :item_type, :string, default: 'item'
      attribute :period, :time_period

      def form_attributes
        attributes.slice('id', 'cost_type', 'period', 'cost_per_hour', 'items', 'item_type', 'cost_per_item')
      end
    end
  end
end
