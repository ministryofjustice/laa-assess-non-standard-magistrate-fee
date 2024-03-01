module PriorAuthority
  module RequestedServiceCosts
    def requested_humanized_units
      if cost_type == 'per_item'
        "#{requested_items} " \
          "#{I18n.t("prior_authority.application_details.items.#{item_type}").pluralize(requested_items)}"
      else
        format_period(requested_period)
      end
    end

    def requested_humanized_cost_per_unit
      I18n.t(
        cost_type,
        gbp: requested_base_cost_per_unit,
        scope: 'prior_authority.application_details.items.per_unit_descriptions'
      )
    end

    def requested_formatted_service_cost_total
      NumberTo.pounds(requested_base_cost)
    end

    def requested_base_cost
      if cost_type == 'per_item'
        requested_items * requested_cost_per_item
      else
        (
          (requested_period.hours * requested_cost_per_hour) +
          ((requested_period.minutes / 60.0) * requested_cost_per_hour)
        ).round(2)
      end
    end

    private

    def requested_items
      value_from_first_event('items') || items
    end

    def requested_period
      # TODO: this could be simplified if the cast time period behaved as a nilClass
      # e.g. Type::TimePeriod.new.cast(value_from_first_event('period')) || period
      requested_period = Type::TimePeriod.new.cast(value_from_first_event('period'))
      return requested_period unless requested_period.nil?

      period
    end

    def requested_base_cost_per_unit
      NumberTo.pounds(requested_cost_per_unit)
    end

    def requested_cost_per_unit
      @requested_cost_per_unit ||= cost_type == 'per_item' ? requested_cost_per_item : requested_cost_per_hour
    end

    def requested_cost_per_item
      (value_from_first_event('cost_per_item') || cost_per_item).to_f
    end

    def requested_cost_per_hour
      (value_from_first_event('cost_per_hour') || cost_per_hour).to_f
    end
  end

  module AdjustedServiceCosts
    include RequestedServiceCosts

    def adjusted_humanized_units
      return unless adjusted_items || adjusted_period

      if cost_type == 'per_item'
        "#{adjusted_items} " \
          "#{I18n.t("prior_authority.application_details.items.#{item_type}").pluralize(adjusted_items)}"
      else
        format_period(adjusted_period)
      end
    end

    def adjusted_humanized_cost_per_unit
      return unless adjusted_formatted_cost_per_unit

      I18n.t(
        cost_type,
        gbp: adjusted_formatted_cost_per_unit,
        scope: 'prior_authority.application_details.items.per_unit_descriptions'
      )
    end

    def adjusted_formatted_service_cost_total
      NumberTo.pounds(adjusted_service_cost_total) if adjusted_service_cost_total
    end

    private

    def adjusted_formatted_cost_per_unit
      NumberTo.pounds(adjusted_cost_per_unit) if adjusted_cost_per_unit
    end

    def adjusted_cost_per_unit
      @adjusted_cost_per_unit ||= cost_type == 'per_item' ? adjusted_cost_per_item : adjusted_cost_per_hour
    end

    def adjusted_service_cost_total
      cost_type == 'per_item' ? adjusted_item_cost_total : adjusted_hour_cost_total
    end

    def adjusted_item_cost_total
      return unless adjusted_items && adjusted_cost_per_item

      adjusted_items * adjusted_cost_per_item
    end

    def adjusted_hour_cost_total
      return unless adjusted_period && adjusted_cost_per_hour

      (
        (adjusted_period.hours * adjusted_cost_per_hour) +
        ((adjusted_period.minutes / 60.0) * adjusted_cost_per_hour)
      ).round(2)
    end

    def adjusted_items
      return unless adjusted_from_value_for('items') || adjusted_from_value_for('cost_per_item')

      adjusted_to_value_for('items') || items
    end

    def adjusted_period
      return unless adjusted_to_value_for('period') || adjusted_to_value_for('cost_per_hour')

      # TODO: this could be simplified if the cast time period behaved as a nilClass
      # e.g. Type::TimePeriod.new.cast(value_to_first_event('period')) || period
      adjusted_period = Type::TimePeriod.new.cast(value_to_first_event('period'))
      return adjusted_period unless adjusted_period.nil?

      period
    end

    def adjusted_cost_per_item
      return unless adjusted_to_value_for('items') || adjusted_to_value_for('cost_per_item')

      (adjusted_to_value_for('cost_per_item') || cost_per_item).to_f
    end

    def adjusted_cost_per_hour
      return unless adjusted_to_value_for('period') || adjusted_to_value_for('cost_per_hour')

      (adjusted_to_value_for('cost_per_hour') || cost_per_hour).to_f
    end
  end

  module ServiceCostsWithAdjustments
    include RequestedServiceCosts
    include AdjustedServiceCosts
  end
end
