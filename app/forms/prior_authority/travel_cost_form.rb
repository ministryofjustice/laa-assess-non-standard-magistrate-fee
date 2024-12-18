module PriorAuthority
  class TravelCostForm < BaseAdjustmentForm
    attribute :id, :string
    attribute :travel_time, :time_period
    attribute :travel_cost_per_hour, :gbp

    validates :travel_time, presence: true, time_period: { allow_zero: true }
    validates :travel_cost_per_hour, presence: true, numericality: { greater_than: 0 }, is_a_number: true

    validates :explanation, presence: true, if: :explanation_required?

    def save
      return false unless valid?

      process_fields

      true
    end

    private

    COMMENT_FIELD = 'travel_adjustment_comment'.freeze

    def process_fields
      process_field(value: travel_time.to_i, field: 'travel_time')
      process_field(value: travel_cost_per_hour.to_s, field: 'travel_cost_per_hour')
    end

    def selected_record
      @selected_record ||= submission.data['quotes'].detect do |row|
        row.fetch('id') == item.id
      end
    end

    def data_has_changed?
      travel_time != item.travel_time ||
        travel_cost_per_hour != item.travel_cost_per_hour
    end
  end
end
