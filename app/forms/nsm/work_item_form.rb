module Nsm
  class WorkItemForm < BaseAdjustmentForm
    LINKED_CLASS = V1::WorkItem
    UPLIFT_PROVIDED = 'no'.freeze
    UPLIFT_RESET = 'yes'.freeze

    attribute :id, :string
    attribute :uplift, :string
    attribute :time_spent, :time_period
    attribute :work_type_value
    attribute :work_item_pricing

    validates :uplift, inclusion: { in: [UPLIFT_PROVIDED, UPLIFT_RESET] }, if: -> { item.uplift? }
    validates :time_spent, allow_nil: true, time_period: { allow_zero: true }

    # overwrite uplift setter to allow value to be passed as either string (form)
    # or integer (initial setup) value
    def uplift=(val)
      case val
      when String then super
      when nil then nil
      else
        super(val.positive? ? 'no' : 'yes')
      end
    end

    def save
      return false unless valid?

      process_fields

      true
    end

    def work_item_prices
      work_item_pricing.keys.index_with do |key|
        claim.rates.work_items[key.to_sym]
      end
    end

    private

    def process_fields
      process_field(value: time_spent.to_i, field: 'time_spent') if time_spent.present?
      process_field(value: new_uplift, field: 'uplift') if item.uplift?
      process_work_item_fields if work_type_changed?
    end

    def process_work_item_fields
      process_field(value: work_type_value, field: 'work_type')
    end

    def selected_record
      @selected_record ||= claim.data['work_items'].detect do |row|
        row.fetch('id') == item.id
      end
    end

    def new_uplift
      uplift == 'yes' ? 0 : item.original_uplift
    end

    def data_has_changed?
      time_spent != item.time_spent ||
        work_type_changed? ||
        (item.uplift? && item.uplift.zero? != (uplift == UPLIFT_RESET))
    end

    def work_type_changed?
      work_type_value != item.work_type.value
    end
  end
end
