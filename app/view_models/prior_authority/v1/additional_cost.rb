module PriorAuthority
  module V1
    class AdditionalCost < BaseWithAdjustments
      LINKED_TYPE = 'additional_costs'.freeze
      ID_FIELDS = %w[id].freeze

      attribute :id, :string
      attribute :name, :string
      attribute :description, :string
      attribute :unit_type, :string
      attribute :items, :integer
      attribute :cost_per_item, :decimal, precision: 10, scale: 2
      attribute :period, :time_period
      attribute :cost_per_hour, :decimal, precision: 10, scale: 2

      def total_cost
        if unit_type == 'per_item'
          items * cost_per_item
        else
          ((period.hours * cost_per_hour) + ((period.minutes / 60.0) * cost_per_hour)).round(2)
        end
      end

      def formatted_total_cost
        NumberTo.pounds(total_cost)
      end

      def form_attributes
        attributes.slice('id', 'period', 'cost_per_hour')
      end

      def unit_description
        if unit_type == 'per_item'
          "#{items} #{I18n.t('prior_authority.application_details.items.item').pluralize(items)}"
        else
          format_period(period)
        end
      end

      def cost_per_unit_description
        NumberTo.pounds(unit_type == 'per_item' ? cost_per_item : cost_per_hour)
      end
    end
  end
end
