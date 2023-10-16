module V1
  class CoreCostSummary < BaseViewModel
    SKIPPED_TYPES = %w[travel waiting].freeze

    attribute :work_items
    attribute :letters_and_calls

    def table_fields
      data_by_type.map do |work_type, total_cost, total_time_spent|
        [
          work_type,
          NumberTo.pounds(total_cost),
          total_time_spent ? "#{total_time_spent}min" : '',
        ]
      end
    end

    def summed_fields
      total_cost = data_by_type.sum { |_, cost, _| cost }
      [
        NumberTo.pounds(total_cost),
        ''
      ]
    end

    private

    def data_by_type
      @data_by_type ||= work_item_data + letter_and_call_data
    end

    def work_item_data
      work_items.map { |work_item| WorkItem.build_self(work_item) }
                .group_by { |work_item| work_item.work_type.to_s }
                .filter_map do |translated_work_type, work_items_for_type|
                  work_type = work_items_for_type.first.work_type
                  next if SKIPPED_TYPES.include?(work_type.value)

                  # TODO: convert this to a time period to enable easy formating of output
                  total_time_spent = work_items_for_type.sum(&:time_spent)
                  total_cost = work_items_for_type.sum { |work_item| CostCalculator.cost(:work_item, work_item) }
                  [
                    translated_work_type,
                    total_cost,
                    total_time_spent,
                  ]
                end
    end

    def letter_and_call_data
      letters_and_calls.filter_map do |hash|
        letter_or_call = LetterAndCall.build_self(hash)
        next if letter_or_call.provider_requested_amount.zero?

        [
          letter_or_call.type.to_s,
          letter_or_call.provider_requested_amount,
          nil
        ]
      end
    end
  end
end
