module V1
  class WorkItemsSummary < BaseViewModel
    attribute :work_items

    def table_fields
      data_by_type.map do |work_type, total_time_spent, total_cost|
        [
          work_type,
          "#{total_time_spent}min",
          NumberTo.pounds(total_cost)
        ]
      end
    end

    def summed_fields
      total_time_spent = data_by_type.sum { |_, time_spent, _| time_spent }
      total_cost = data_by_type.sum { |_, _, cost| cost }
      [
        "#{total_time_spent}min",
        NumberTo.pounds(total_cost)
      ]
    end

    private

    def data_by_type
      @data_by_type ||= begin
        by_work_item = work_items.group_by { |work_item| work_item['work_type'] }

        by_work_item.map do |work_type, work_items_for_type|
          # TODO: convert this to a time period to enable easy formating of output
          total_time_spent = work_items_for_type.sum { |work_item| work_item['time_spent'] }
          total_cost = work_items_for_type.sum { |work_item| CostCalculator.cost(:work_item, work_item) }
          [
            work_type,
            total_time_spent,
            total_cost
          ]
        end
      end
    end
  end
end
