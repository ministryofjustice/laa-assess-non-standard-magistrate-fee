module PriorAuthority
  class ServiceCostForm < BaseAdjustmentForm
    LINKED_CLASS = V1::ServiceCost

    PER_ITEM = 'per_item'.freeze
    PER_HOUR = 'per_hour'.freeze

    attribute :id, :string
    attribute :cost_type, :string
    attribute :item_type, :string
    attribute :service_type, :string

    attribute :period, :time_period
    attribute :cost_per_hour, :gbp
    attribute :items, :integer
    attribute :cost_per_item, :gbp

    with_options if: :per_item? do
      validates :items, presence: true, numericality: { greater_than: 0 }, is_a_number: true
      validates :cost_per_item, presence: true, numericality: { greater_than: 0 }, is_a_number: true
    end

    with_options if: :per_hour? do
      validates :period, presence: true, time_period: true
      validates :cost_per_hour, presence: true, numericality: { greater_than: 0 }, is_a_number: true
    end

    def save
      return false unless valid?

      PriorAuthorityApplication.transaction do
        process_fields
        submission.save
      end

      true
    end

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

    def data_has_changed?
      period != item.period || cost_per_hour != item.cost_per_hour
    end
  end
end
