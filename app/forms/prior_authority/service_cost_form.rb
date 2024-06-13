module PriorAuthority
  class ServiceCostForm < BaseCostAdjustmentForm
    LINKED_CLASS = V1::ServiceCost

    attribute :cost_type, :string
    attribute :item_type, :string
    attribute :service_type, :string
    attribute :cost_item_type, :string

    def per_item?
      cost_type == PER_ITEM
    end

    def per_hour?
      cost_type == PER_HOUR
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
      @selected_record ||= submission.data['quotes'].detect do |row|
        row.fetch('id') == item.id
      end
    end
  end
end
