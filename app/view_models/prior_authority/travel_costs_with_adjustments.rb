module PriorAuthority
  module RequestedTravelCosts
    def requested_travel_units
      format_period(requested_travel_time)
    end

    def requested_formatted_travel_cost_per_hour
      return if requested_travel_cost_per_hour.zero?

      I18n.t(
        'per_hour',
        gbp: NumberTo.pounds(requested_travel_cost_per_hour),
        scope: 'prior_authority.application_details.items.per_unit_descriptions'
      )
    end

    def requested_formatted_travel_cost
      NumberTo.pounds(requested_travel_costs) if requested_travel_costs
    end

    private

    def requested_travel_costs
      return if requested_travel_time.nil? || requested_travel_cost_per_hour.zero?

      (
        (requested_travel_time.hours * requested_travel_cost_per_hour) +
        ((requested_travel_time.minutes / 60.0) * requested_travel_cost_per_hour)
      ).round(2)
    end

    def requested_travel_time
      original_travel_time
    end

    def requested_travel_cost_per_hour
      original_travel_cost_per_hour.to_f
    end
  end

  module AdjustedTravelCosts
    def adjusted_travel_units
      format_period(adjusted_travel_time) if adjusted_travel_time
    end

    def adjusted_formatted_travel_cost_per_hour
      return unless adjusted_travel_cost_per_hour

      I18n.t(
        'per_hour',
        gbp: NumberTo.pounds(adjusted_travel_cost_per_hour),
        scope: 'prior_authority.application_details.items.per_unit_descriptions'
      )
    end

    def adjusted_formatted_travel_cost
      NumberTo.pounds(adjusted_travel_costs) if adjusted_travel_costs
    end

    private

    def adjusted_travel_costs
      return unless adjusted_travel_time.to_i.positive? && adjusted_travel_cost_per_hour.to_f.positive?

      (
        (adjusted_travel_time.hours * adjusted_travel_cost_per_hour) +
        ((adjusted_travel_time.minutes / 60.0) * adjusted_travel_cost_per_hour)
      ).round(2)
    end

    def adjusted_travel_time
      travel_time if travel_time_original || travel_cost_per_hour_original
    end

    def adjusted_travel_cost_per_hour
      travel_cost_per_hour if travel_cost_per_hour_original || travel_time_original
    end
  end

  module TravelCostsWithAdjustments
    include RequestedTravelCosts
    include AdjustedTravelCosts
  end
end
