module PriorAuthority
  module V1
    class Quote < BaseViewModel
      attribute :id, :string
      attribute :cost_type, :string
      attribute :cost_per_hour, :decimal, precision: 10, scale: 2
      attribute :cost_per_item, :decimal, precision: 10, scale: 2
      attribute :items, :integer
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

      def travel_costs
        return 0 unless travel_time.to_i.positive? && travel_cost_per_hour.to_f.positive?

        ((travel_time.hours * travel_cost_per_hour) + ((travel_time.minutes / 60.0) * travel_cost_per_hour)).round(2)
      end

      def total_additional_costs
        additional_costs.sum(&:total_cost)
      end

      def additional_costs
        @additional_costs ||= additional_cost_json.map { AdditionalCost.new(_1) }
      end
    end
  end
end
