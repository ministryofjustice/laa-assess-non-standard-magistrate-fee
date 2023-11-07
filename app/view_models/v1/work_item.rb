module V1
  class WorkItem < BaseWithAdjustments
    attribute :id, :string
    attribute :work_type, :translated
    # TODO: import time_period code from provider app
    attribute :time_spent
    attribute :completed_on, :date

    attribute :pricing, :float
    attribute :uplift, :integer
    attribute :fee_earner, :string

    def provider_requested_amount
      CostCalculator.cost(:work_item, self, :provider_requested)
    end

    def provider_requested_uplift
      @provider_requested_uplift ||= value_from_first_event('uplift') || uplift.to_i
    end

    def caseworker_amount
      @caseworker_amount ||= CostCalculator.cost(:work_item, self, :caseworker)
    end

    def caseworker_uplift
      uplift.to_i
    end

    def uplift?
      !provider_requested_uplift.to_i.zero?
    end

    def table_fields
      [
        work_type.to_s,
        "#{provider_requested_uplift.to_i}%",
        "#{NumberTo.pounds(provider_requested_amount)}",
        adjustments.any? ? "#{caseworker_uplift}%" : '',
        adjustments.any? ? NumberTo.pounds(caseworker_amount) : '',
      ]
    end
  end
end
