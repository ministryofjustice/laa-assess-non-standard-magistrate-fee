module PriorAuthority
  class AdditionalCostForm < BaseAdjustmentForm
    LINKED_CLASS = V1::AdditionalCost

    attribute :id, :string
    attribute :time_spent, :time_period
    attribute :cost_per_hour, :float

    validates :time_spent, allow_nil: true, time_period: true

    def save
      return false unless valid?

      process_field(value: time_spent.to_i, field: 'time_spent')

      AppStoreService.adjust(submission, metadata)

      true
    end

    private

    def selected_record
      @selected_record ||= submission.data['additional_costs'].detect do |row|
        row.fetch('id') == item.id
      end
    end

    def data_has_changed?
      time_spent != item.time_spent || cost_per_hour != item.cost_per_hour
    end
  end
end
