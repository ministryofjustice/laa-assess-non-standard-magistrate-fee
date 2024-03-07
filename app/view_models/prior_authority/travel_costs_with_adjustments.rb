module PriorAuthority
  module RequestedTravelCosts
    def requested_travel_units
      format_period(original_travel_time)
    end

    def requested_formatted_travel_cost_per_hour
      return if original_travel_cost_per_hour.to_f.zero?

      "#{NumberTo.pounds(original_travel_cost_per_hour)} " \
        "#{I18n.t('prior_authority.application_details.items.per_unit_descriptions.per_hour')}"
    end

    def requested_formatted_travel_cost
      NumberTo.pounds(requested_travel_costs) if requested_travel_costs
    end

    private

    def requested_travel_costs
      return if original_travel_time.nil? || original_travel_cost_per_hour.to_f.zero?

      (
        (original_travel_time.hours * original_travel_cost_per_hour) +
        ((original_travel_time.minutes / 60.0) * original_travel_cost_per_hour)
      ).round(2)
    end
  end

  module AdjustedTravelCosts
    def adjusted_travel_units
      format_period(travel_time) if any_travel_adjustments?
    end

    def adjusted_formatted_travel_cost_per_hour
      return unless any_travel_adjustments?

      "#{NumberTo.pounds(travel_cost_per_hour)} " \
        "#{I18n.t('prior_authority.application_details.items.per_unit_descriptions.per_hour')}"
    end

    def adjusted_formatted_travel_cost
      NumberTo.pounds(adjusted_travel_costs) if any_travel_adjustments?
    end

    private

    def adjusted_travel_costs
      (
        (travel_time.hours * travel_cost_per_hour) +
        ((travel_time.minutes / 60.0) * travel_cost_per_hour)
      ).round(2)
    end

    def any_travel_adjustments?
      travel_time_original || travel_cost_per_hour_original
    end
  end

  # NOTE: since the requested/adjusted mixin helpers are large and required together we add a thin wrapper module
  module TravelCostsWithAdjustments
    include RequestedTravelCosts
    include AdjustedTravelCosts
  end
end
