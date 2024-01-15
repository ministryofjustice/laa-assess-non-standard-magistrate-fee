module PriorAuthority
  module V1
    class AdditionalCost < BaseWithAdjustments
      LINKED_TYPE = 'work_items'.freeze
      ID_FIELDS = %w[id].freeze

      attribute :id, :string
      attribute :time_spent, :time_period
      attribute :cost_per_hour, :float
      attribute :description, :string

      def total_cost
        ((time_spent.hours * cost_per_hour) + ((time_spent.minutes / 60.0) * cost_per_hour)).round(2)
      end

      def form_attributes
        attributes.slice('id', 'time_spent', 'cost_per_hour')
      end
    end
  end
end
