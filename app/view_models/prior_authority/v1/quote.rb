module PriorAuthority
  module V1
    class Quote < BaseWithAdjustments
      attribute :id, :string
      attribute :cost_type, :string
      adjustable_attribute :cost_per_hour, :decimal, precision: 10, scale: 2
      adjustable_attribute :cost_per_item, :decimal, precision: 10, scale: 2
      adjustable_attribute :items, :integer
      attribute :item_type, :string, default: 'item'
      adjustable_attribute :period, :time_period

      adjustable_attribute :travel_time, :time_period
      adjustable_attribute :travel_cost_per_hour, :decimal, precision: 10, scale: 2
      attribute :travel_cost_reason, :string

      attribute :additional_cost_json
      attribute :additional_cost_list, :string
      adjustable_attribute :additional_cost_total, :decimal, precision: 10, scale: 2

      attribute :contact_full_name, :string
      attribute :organisation, :string
      attribute :postcode, :string
      attribute :primary, :boolean
      attribute :ordered_by_court, :boolean
      attribute :related_to_post_mortem, :boolean
      attribute :document

      def total_cost
        base_cost + travel_costs + total_additional_costs
      end

      def original_total_cost
        base_cost(original: true) + travel_costs(original: true) + total_additional_costs(original: true)
      end

      def base_cost(original: false)
        if cost_type == 'per_item'
          original ? original_total_item_cost : total_item_cost
        else
          period_to_consider = original ? original_period : period
          hourly_cost = original ? original_cost_per_hour : cost_per_hour
          ((period_to_consider.hours * hourly_cost) + ((period_to_consider.minutes / 60.0) * hourly_cost)).round(2)
        end
      end

      def total_item_cost
        items * cost_per_item
      end

      def original_total_item_cost
        original_items * original_cost_per_item
      end

      def base_units
        if cost_type == 'per_item'
          "#{items} #{I18n.t("prior_authority.application_details.items.#{item_type}").pluralize(items)}"
        else
          format_period(period)
        end
      end

      def travel_units
        format_period(travel_time)
      end

      def travel_cost_per_unit
        NumberTo.pounds(travel_cost_per_hour)
      end

      def formatted_travel_cost_per_unit
        I18n.t('per_hour',
               gbp: travel_cost_per_unit,
               scope: 'prior_authority.application_details.items.per_unit_descriptions')
      end

      def base_cost_per_unit
        NumberTo.pounds(cost_type == 'per_item' ? cost_per_item : cost_per_hour)
      end

      def formatted_base_cost_per_unit
        I18n.t(cost_type,
               gbp: base_cost_per_unit,
               item: I18n.t("prior_authority.application_details.items.#{item_type}"),
               scope: 'prior_authority.application_details.items.per_unit_descriptions')
      end

      def formatted_base_cost
        NumberTo.pounds(base_cost)
      end

      def formatted_travel_cost
        NumberTo.pounds(travel_costs)
      end

      def formatted_additional_costs
        NumberTo.pounds(total_additional_costs)
      end

      def formatted_total_cost
        NumberTo.pounds(total_cost)
      end

      def travel_costs(original: false)
        time = original ? original_travel_time : travel_time
        hourly_cost = original ? original_travel_cost_per_hour : travel_cost_per_hour
        return 0 unless time.to_i.positive? && hourly_cost.to_f.positive?

        ((time.hours * hourly_cost) + ((time.minutes / 60.0) * hourly_cost)).round(2)
      end

      def total_additional_costs(original: false)
        if additional_costs.present?
          additional_costs.sum { _1.total_cost(original:) }
        else
          (original ? original_additional_cost_total : additional_cost_total).to_i
        end
      end

      def additional_costs
        @additional_costs ||= additional_cost_json&.map { AdditionalCost.new(_1) }
      end

      def uploaded_document
        @uploaded_document ||= Document.new(document)
      end
    end
  end
end
