module PriorAuthority
  class TravelCostForm < BaseAdjustmentForm
    LINKED_CLASS = V1::TravelCost

    attribute :id, :string
    attribute :travel_time, :time_period
    attribute :travel_cost_per_hour, :gbp

    validates :travel_time, presence: true, time_period: true
    validates :travel_cost_per_hour, presence: true, numericality: { greater_than: 0 }, is_a_number: true

    validates :explanation, presence: true, if: :explanation_required?

    def save
      return false unless valid?

      PriorAuthorityApplication.transaction do
        process_fields
        submission.save
      end

      true
    end

    private

    def process_fields
      comment_field = 'travel_adjustment_comment'

      process_field(value: travel_time.to_i, field: 'travel_time', comment_field: comment_field)
      process_field(value: travel_cost_per_hour.to_s, field: 'travel_cost_per_hour', comment_field: comment_field)
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
