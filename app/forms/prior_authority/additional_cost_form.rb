module PriorAuthority
  class AdditionalCostForm < BaseCostAdjustmentForm
    LINKED_CLASS = V1::AdditionalCost

    attribute :unit_type, :string

    def per_item?
      unit_type == PER_ITEM
    end

    def per_hour?
      unit_type == PER_HOUR
    end

    private

    def process_fields
      if per_hour?
        process_field(value: period.to_i, field: 'period')
        process_field(value: cost_per_hour.to_s, field: 'cost_per_hour')
      else
        process_field(value: items.to_i, field: 'items')
        process_field(value: cost_per_item, field: 'cost_per_item')
      end
    end

    def selected_record
      @selected_record ||= submission.data['additional_costs'].detect do |row|
        row.fetch('id') == item.id
      end
    end
  end
end
