module PriorAuthority
  class AdditionalCostForm < BaseAdjustmentForm
    LINKED_CLASS = V1::AdditionalCost

    attribute :id, :string
    attribute :period, :time_period
    attribute :cost_per_hour, :float

    validates :period, allow_nil: true, time_period: true

    def save
      return false unless valid?

      PriorAuthorityApplication.transaction do
        process_field(value: period.to_i, field: 'period')

        submission.save
      end

      true
    end

    private

    def selected_record
      @selected_record ||= submission.data['additional_costs'].detect do |row|
        row.fetch('id') == item.id
      end
    end

    def data_has_changed?
      period != item.period || cost_per_hour != item.cost_per_hour
    end
  end
end
