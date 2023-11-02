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
      CostCalculator.cost(:work_item, self)
    end

    def requested
      # TODO: update once we can calculate adjustments
      time_spent - 0 # adjustments
    end

    def adjustments
      '#pending#'
    end

    def uplift?
      !uplift.to_i.zero?
    end

    def table_fields
      [
        work_type.to_s,
        "#{uplift.to_i}%",
        "#{requested}min",
        '#pending#',
        '#pending#'
      ]
    end
  end
end
