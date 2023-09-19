module V1
  class WorkItem < BaseViewModel
    # TODO: include translated_work_item (EN) in json feed
    attribute :work_type, :translated
    # TODO: import time_period code from provider app
    attribute :time_spent
    attribute :completed_on, :date

    attribute :pricing, :float
    attribute :uplift, :integer

    def adjustment
      '#pending#'
    end

    def table_fields
      [work_type.to_s, "#{time_spent}min", adjustment]
    end
  end
end
