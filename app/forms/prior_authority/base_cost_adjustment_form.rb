module PriorAuthority
  class BaseCostAdjustmentForm < BaseAdjustmentForm
    PER_ITEM = 'per_item'.freeze
    PER_HOUR = 'per_hour'.freeze

    attribute :id, :string

    attribute :items, :fully_validatable_integer
    attribute :cost_per_item, :gbp
    attribute :period, :time_period
    attribute :cost_per_hour, :gbp

    with_options if: :per_item? do
      validates :items, item_type_dependant: { pluralize: true }
      validates :cost_per_item, item_type_dependant: true
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

    # :nocov:
    def per_item?
      raise 'Implement in subclass'
    end
    # :nocov:

    # :nocov:
    def per_hour?
      raise 'Implement in subclass'
    end
    # :nocov:

    private

    # :nocov:
    def process_fields
      raise 'Implement in subclass'
    end
    # :nocov:

    def data_has_changed?
      if per_hour?
        period != item.period || cost_per_hour != item.cost_per_hour
      else
        items != item.items || cost_per_item != item.cost_per_item
      end
    end
  end
end
