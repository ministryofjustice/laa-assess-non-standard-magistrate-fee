module V1
  class WorkItem < BaseViewModel
    attribute :work_type, :translated
    # TODO: import time_period code from provider app
    attribute :time_spent
    attribute :completed_on, :date

    attribute :pricing, :float
    attribute :uplift, :integer

    def requested
      # TODO: update once we can calculate adjustments
      time_spent - 0 # adjustments
    end

    def adjustments
      '#pending#'
    end

    def table_fields
      [work_type.to_s, "#{uplift.to_i}%", "#{requested}min", '#pending#', '#pending#']
    end
  end
end
