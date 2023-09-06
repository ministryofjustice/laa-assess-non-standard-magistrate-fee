module V1
  class WorkItem < BaseViewModel
    attribute :id
    attribute :uplift
    attribute :rate
    attribute :work_type
    attribute :fee_earner
    attribute :time_spent
    attribute :completed_on, :date

    attribute :total
    attribute :total_without_uplift
    attribute :total_with_uplift

    def adjustment
      '#pending#'
    end

    def table_fields
      [work_type, "#{time_spent}min", adjustment]
    end
  end
end
