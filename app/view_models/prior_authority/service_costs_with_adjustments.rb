module PriorAuthority
  module RequestedServiceCosts
    def requested_humanized_units
      if cost_type == 'per_item'
        "#{original_items} " \
          "#{I18n.t("prior_authority.application_details.items.#{item_type}").pluralize(original_items)}"
      else
        format_period(original_period)
      end
    end

    def requested_humanized_cost_per_unit
      i18n_key = cost_type == 'per_item' ? "per_#{item_type}" : cost_type

      "#{requested_formatted_cost_per_unit} " \
        "#{I18n.t(i18n_key, scope: 'prior_authority.application_details.items.per_unit_descriptions')}"
    end

    def requested_formatted_service_cost_total
      NumberTo.pounds(requested_service_cost_total)
    end

    private

    def requested_service_cost_total
      if cost_type == 'per_item'
        original_items * original_cost_per_item
      else
        (
          (original_period.hours * original_cost_per_hour) +
          ((original_period.minutes / 60.0) * original_cost_per_hour)
        ).round(2)
      end
    end

    def requested_formatted_cost_per_unit
      NumberTo.pounds(requested_cost_per_unit)
    end

    def requested_cost_per_unit
      cost_type == 'per_item' ? original_cost_per_item : original_cost_per_hour
    end
  end

  module AdjustedServiceCosts
    include RequestedServiceCosts

    def adjusted_humanized_units
      return unless any_adjustments?

      if cost_type == 'per_item'
        "#{items} " \
          "#{I18n.t("prior_authority.application_details.items.#{item_type}").pluralize(items)}"
      else
        format_period(period)
      end
    end

    def adjusted_humanized_cost_per_unit
      return unless any_adjustments?

      i18n_key = cost_type == 'per_item' ? "per_#{item_type}" : cost_type

      "#{adjusted_formatted_cost_per_unit} " \
        "#{I18n.t(i18n_key, scope: 'prior_authority.application_details.items.per_unit_descriptions')}"
    end

    def adjusted_formatted_service_cost_total
      NumberTo.pounds(adjusted_service_cost_total) if any_adjustments?
    end

    private

    def adjusted_formatted_cost_per_unit
      NumberTo.pounds(adjusted_cost_per_unit)
    end

    def adjusted_cost_per_unit
      cost_type == 'per_item' ? cost_per_item : cost_per_hour
    end

    def adjusted_service_cost_total
      cost_type == 'per_item' ? adjusted_item_cost_total : adjusted_hour_cost_total
    end

    def adjusted_item_cost_total
      items * cost_per_item
    end

    def adjusted_hour_cost_total
      (
        (period.hours * cost_per_hour) +
        ((period.minutes / 60.0) * cost_per_hour)
      ).round(2)
    end

    def any_adjustments?
      any_per_item_adjustments? || any_per_hour_adjustments?
    end

    def any_per_item_adjustments?
      items_original || cost_per_item_original
    end

    def any_per_hour_adjustments?
      period_original || cost_per_hour_original
    end
  end

  # NOTE: since the requested/adjusted mixin helpers are required together we add a thin wrapper module
  module ServiceCostsWithAdjustments
    include RequestedServiceCosts
    include AdjustedServiceCosts
  end
end
