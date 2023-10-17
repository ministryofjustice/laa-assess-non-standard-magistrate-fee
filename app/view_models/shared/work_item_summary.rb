module Shared
  module WorkItemSummary
    def work_item_data
      @work_item_data ||=
        grouped_work_items
        .filter_map do |translated_work_type, work_items_for_type|
          next if skip_work_item?(work_items_for_type.first)

          # TODO: convert this to a time period to enable easy formating of output
          [
            translated_work_type,
            work_items_for_type.sum { |work_item| CostCalculator.cost(:work_item, work_item) },
            work_items_for_type.sum(&:time_spent),
          ]
        end
    end

    private

    def grouped_work_items
      work_items.map { |work_item| class_scope::WorkItem.build_self(work_item) }
                .group_by { |work_item| work_item.work_type.to_s }
    end

    # overwrite if you need custom filtering
    # :nocov:
    def skip_work_item?(*)
      false
    end
    # :nocov:

    def class_scope
      @class_scope ||= self.class.module_parent
    end
  end
end
