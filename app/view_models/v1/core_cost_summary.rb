module V1
  class CoreCostSummary < BaseViewModel
    SKIPPED_TYPES = %w[travel waiting].freeze
]

    attribute :work_items, :letters_annd_calls

    def table_fields
      data_by_type.map do |work_type, total_time_spent, total_cost|
        [
          work_type,
          NumberTo.pounds(total_cost),
          "#{total_time_spent}min",
        ]
      end
    end

    def summed_fields
      total_time_spent = data_by_type.sum { |_, time_spent, _| time_spent }
      total_cost = data_by_type.sum { |_, _, cost| cost }
      [
        NumberTo.pounds(total_cost),
        "#{total_time_spent}min",
      ]
    end

    private

    def data_by_type
      @data_by_type ||=
        work_items.map { |work_item| WorkItem.build_self(work_item) }
                  .group_by { |work_item| work_item.work_type.to_s }
                  .filter_map do |work_type, work_items_for_type|
                    next if SKIPPED_TYPES.include?(work_type)
                    # TODO: convert this to a time period to enable easy formating of output
                    total_time_spent = work_items_for_type.sum(&:time_spent)
                    total_cost = work_items_for_type.sum { |work_item| CostCalculator.cost(:work_item, work_item) }
                    [
                      work_type,
                      total_cost,
                      total_time_spent,
                    ]
                  end
    end
  end
end
