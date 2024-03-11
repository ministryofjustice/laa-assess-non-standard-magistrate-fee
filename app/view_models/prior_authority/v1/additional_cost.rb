module PriorAuthority
  module V1
    class AdditionalCost < BaseWithAdjustments
      LINKED_TYPE = 'additional_costs'.freeze

      include AdditionalCostsWithAdjustments

      attribute :id, :string
      attribute :name, :string
      attribute :description, :string
      attribute :unit_type, :string
      adjustable_attribute :items, :integer
      adjustable_attribute :cost_per_item, :decimal, precision: 10, scale: 2
      adjustable_attribute :period, :time_period
      adjustable_attribute :cost_per_hour, :decimal, precision: 10, scale: 2

      def total_cost(original: false)
        if unit_type == 'per_item'
          total_item_cost(original)
        else
          period_to_consider = original ? original_period : period
          hourly_cost = original ? original_cost_per_hour : cost_per_hour
          ((period_to_consider.hours * hourly_cost) + ((period_to_consider.minutes / 60.0) * hourly_cost)).round(2)
        end
      end

      def total_item_cost(original)
        if original
          original_items * original_cost_per_item
        else
          items * cost_per_item
        end
      end

      def formatted_total_cost
        NumberTo.pounds(total_cost(original: true))
      end

      def form_attributes
        attributes.slice('id', 'unit_type', 'period', 'cost_per_hour', 'items', 'cost_per_item')
      end

      def unit_label
        I18n.t(unit_type, scope: 'prior_authority.application_details.items.unit_description')
      end

      def original_unit_description
        if unit_type == 'per_item'
          "#{original_items} #{I18n.t('prior_authority.application_details.items.item').pluralize(original_items)}"
        else
          format_period(original_period)
        end
      end

      def original_cost_per_unit
        NumberTo.pounds(unit_type == 'per_item' ? original_cost_per_item : original_cost_per_hour)
      end
    end
  end
end
