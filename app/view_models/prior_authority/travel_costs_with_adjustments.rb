module PriorAuthority
  module RequestedTravelCosts
    def requested_travel_units
      format_period(requested_travel_time)
    end

    def requested_formatted_travel_cost_per_hour
      I18n.t(
        'per_hour',
        gbp: NumberTo.pounds(requested_travel_cost_per_hour),
        scope: 'prior_authority.application_details.items.per_unit_descriptions'
      )
    end

    def requested_formatted_travel_cost
      NumberTo.pounds(requested_travel_costs)
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
      # TODO: this could be simplified if the cast time prriod behaved as a nilClass
      # e.g. Type::TimePeriod.new.cast(value_from_first_event('travel_time')) || travel_time
      requested_travel_time = Type::TimePeriod.new.cast(value_from_first_event('travel_time'))
      return requested_travel_time unless requested_travel_time.nil?

      travel_time
    end

    def requested_travel_cost_per_hour
      (value_from_first_event('travel_cost_per_hour') || travel_cost_per_hour).to_f
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
      return unless adjusted_to_value_for('travel_time') || adjusted_to_value_for('travel_cost_per_hour')

      # TODO: this could be simplified if the cast time period behaved as a nilClass
      # e.g. Type::TimePeriod.new.cast(value_to_first_event('travel_time')) || travel_time
      adjusted_travel_time = Type::TimePeriod.new.cast(value_to_first_event('travel_time'))
      return adjusted_travel_time unless adjusted_travel_time.nil?

      travel_time
    end

    def adjusted_travel_cost_per_hour
      return unless adjusted_to_value_for('travel_time') || adjusted_to_value_for('travel_cost_per_hour')

      (value_to_first_event('travel_cost_per_hour') || travel_cost_per_hour).to_f
    end
  end

  module TravelCostsWithAdjustments
    include RequestedTravelCosts
    include AdjustedTravelCosts
  end
end
