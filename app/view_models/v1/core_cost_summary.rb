module V1
  class CoreCostSummary < BaseViewModel
    include V1::WorkItemSummary

    SKIPPED_TYPES = %w[travel waiting].freeze

    attribute :claim

    def table_fields
      data_by_type.map do |work_type, _, _, allowed_cost, allowed_time|
        [
          work_type,
          NumberTo.pounds(allowed_cost),
          allowed_time ? "#{allowed_time}min" : '',
        ]
      end
    end

    def summed_fields
      total_cost = data_by_type.sum { |_, _, _, cost, _| cost }
      [
        NumberTo.pounds(total_cost),
        ''
      ]
    end

    private

    def data_by_type
      @data_by_type ||= work_item_data + letter_and_call_data
    end

    def skip_work_item?(work_item)
      SKIPPED_TYPES.include?(work_item.work_type.value)
    end

    def letter_and_call_data
      rows = LettersAndCallsSummary.new('claim' => claim).rows
      rows.filter_map do |letter_or_call|
        next if letter_or_call.provider_requested_count.zero?

        [
          letter_or_call.type.to_s,
          letter_or_call.provider_requested_amount,
          nil,
          letter_or_call.allowed_amount,
          nil
        ]
      end
    end
  end
end
