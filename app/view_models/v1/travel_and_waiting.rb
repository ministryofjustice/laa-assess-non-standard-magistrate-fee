module V1
  class TravelAndWaiting < BaseViewModel
    INCLUDED_TYPES = %w[travel waiting].freeze

    attribute :work_items

    def table_fields
      work_item_data.map do |work_type, total_cost, total_time_spent|
        [
          work_type,
          NumberTo.pounds(total_cost),
          "#{total_time_spent}min",
        ]
      end
    end

    def total_cost
      NumberTo.pounds(
        work_item_data.sum { |_, total_cost, _| total_cost }
      )
    end

    delegate :any?, to: :work_item_data

    private

    # rubocop:disable Metrics/CyclomaticComplexity
    def work_item_data
      @work_item_data ||=
        work_items.map { |work_item| WorkItem.build_self(work_item) }
                  .group_by { |work_item| work_item.work_type.to_s }
                  .filter_map do |translated_work_type, work_items_for_type|
                    work_type = work_items_for_type.first.work_type
                    next unless INCLUDED_TYPES.include?(work_type.value)

                    # TODO: convert this to a time period to enable easy formating of output
                    [
                      translated_work_type,
                      work_items_for_type.sum { |work_item| CostCalculator.cost(:work_item, work_item) },
                      work_items_for_type.sum(&:time_spent),
                    ]
                  end
    end
    # rubocop:enable Metrics/CyclomaticComplexity
  end
end
