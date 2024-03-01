module PriorAuthority
  module V1
    class TravelCost < BaseWithAdjustments
      LINKED_TYPE = 'quotes'.freeze

      attribute :id, :string
      attribute :travel_time, :time_period
      attribute :travel_cost_per_hour, :gbp

      def form_attributes
        attributes.slice('id', 'travel_time', 'travel_cost_per_hour')
      end
    end
  end
end
