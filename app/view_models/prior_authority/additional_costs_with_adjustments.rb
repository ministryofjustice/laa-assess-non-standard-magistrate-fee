module PriorAuthority
  module RequestedAdditionalCosts
    def requested_humanized_units
      if unit_type == 'per_item'
        "#{requested_items} " \
          "#{I18n.t('prior_authority.application_details.items.item').pluralize(requested_items)}"
      else
        format_period(requested_period)
      end
    end

    def requested_humanized_cost_per_unit
      "#{requested_base_cost_per_unit} " \
        "#{I18n.t(unit_type, scope: 'prior_authority.application_details.items.per_unit_descriptions')}"
    end

    def requested_formatted_cost_total
      NumberTo.pounds(requested_base_cost)
    end

    private

    def requested_items
      original_items
    end

    def requested_period
      original_period
    end

    def requested_base_cost
      if unit_type == 'per_item'
        requested_items * requested_cost_per_item
      else
        (
          (requested_period.hours * requested_cost_per_hour) +
          ((requested_period.minutes / 60.0) * requested_cost_per_hour)
        ).round(2)
      end
    end

    def requested_base_cost_per_unit
      NumberTo.pounds(requested_cost_per_unit)
    end

    def requested_cost_per_unit
      @requested_cost_per_unit ||= unit_type == 'per_item' ? requested_cost_per_item : requested_cost_per_hour
    end

    def requested_cost_per_item
      original_cost_per_item
    end

    def requested_cost_per_hour
      original_cost_per_hour
    end
  end

  module AdjustedAdditionalCosts
    def adjusted_humanized_units
      return unless adjusted_items || adjusted_period

      if unit_type == 'per_item'
        "#{adjusted_items} " \
          "#{I18n.t('prior_authority.application_details.items.item').pluralize(adjusted_items)}"
      else
        format_period(adjusted_period)
      end
    end

    def adjusted_humanized_cost_per_unit
      return unless adjusted_formatted_cost_per_unit

      "#{adjusted_formatted_cost_per_unit} " \
        "#{I18n.t(unit_type, scope: 'prior_authority.application_details.items.per_unit_descriptions')}"
    end

    def adjusted_formatted_cost_total
      NumberTo.pounds(adjusted_cost_total) if adjusted_cost_total
    end

    private

    def adjusted_formatted_cost_per_unit
      NumberTo.pounds(adjusted_cost_per_unit) if adjusted_cost_per_unit
    end

    def adjusted_cost_per_unit
      @adjusted_cost_per_unit ||= unit_type == 'per_item' ? adjusted_cost_per_item : adjusted_cost_per_hour
    end

    def adjusted_cost_total
      unit_type == 'per_item' ? adjusted_item_cost_total : adjusted_hour_cost_total
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
      items if items_original || cost_per_item_original
    end

    def adjusted_period
      period if period_original || cost_per_hour_original
    end

    def adjusted_cost_per_item
      cost_per_item if cost_per_item_original || items_original
    end

    def adjusted_cost_per_hour
      cost_per_hour if cost_per_hour_original || period_original
    end
  end

  module AdditionalCostsWithAdjustments
    include RequestedAdditionalCosts
    include AdjustedAdditionalCosts
  end
end
