module V1
  class WorkItem < BaseViewModel
    # TODO: include translated_work_item (EN) in json feed
    attribute :work_type
    # TODO: import time_period code from provider app
    attribute :time_spent
    attribute :completed_on, :date

    def adjustment
      '#pending#'
    end

    def table_fields
      [work_type, "#{time_spent}min", adjustment]
    end
  end
end
