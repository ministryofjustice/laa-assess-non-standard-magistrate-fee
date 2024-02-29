module PriorAuthority
  module V1
    class Quote < BaseViewModel
      attribute :id, :string
      attribute :cost_type, :string
      attribute :cost_per_hour, :decimal, precision: 10, scale: 2
      attribute :cost_per_item, :decimal, precision: 10, scale: 2
      attribute :items, :integer
      attribute :item_type, :string, default: 'item'
      attribute :period, :time_period

      attribute :travel_time, :time_period
      attribute :travel_cost_per_hour, :decimal, precision: 10, scale: 2
      attribute :travel_cost_reason, :string

      attribute :additional_cost_json
      attribute :additional_cost_list, :string
      attribute :additional_cost_total, :decimal, precision: 10, scale: 2

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

      def base_cost
        if cost_type == 'per_item'
          items * cost_per_item
        else
          ((period.hours * cost_per_hour) + ((period.minutes / 60.0) * cost_per_hour)).round(2)
        end
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
        I18n.t(
          'per_hour',
          gbp: travel_cost_per_unit,
          scope: 'prior_authority.application_details.items.per_unit_descriptions'
        )
      end

      def base_cost_per_unit
        NumberTo.pounds(cost_type == 'per_item' ? cost_per_item : cost_per_hour)
      end

      def formatted_base_cost_per_unit
        I18n.t(
          cost_type,
          gbp: base_cost_per_unit,
          scope: 'prior_authority.application_details.items.per_unit_descriptions'
        )
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

      def travel_costs
        return 0 unless travel_time.to_i.positive? && travel_cost_per_hour.to_f.positive?

        ((travel_time.hours * travel_cost_per_hour) + ((travel_time.minutes / 60.0) * travel_cost_per_hour)).round(2)
      end

      def total_additional_costs
        if additional_costs.present?
          additional_costs.sum(&:total_cost)
        elsif additional_cost_total.to_i.positive?
          additional_cost_total
        else
          0
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
