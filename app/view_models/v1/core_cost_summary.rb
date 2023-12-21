module V1
  class CoreCostSummary < BaseViewModel
    include V1::WorkItemSummary

    SKIPPED_TYPES = %w[travel waiting].freeze

    attribute :claim
    attribute :firm_office

    def vat_registered?
      firm_office['vat_registered'] == 'yes'
    end

    def table_fields
      data_by_type.map do |work_type, requested_cost, requested_time, allowed_cost, _allowed_time|
        [
          work_type,
          requested_time ? "#{requested_time}min" : '',
          NumberTo.pounds(requested_cost, round_mode: vat_registered? ? :down : :half_up),
          NumberTo.pounds(allowed_cost, round_mode: vat_registered? ? :down : :half_up),
        ]
      end
    end

    def summed_fields
      allowed_cost = data_by_type.sum { |_, _, _, cost, _| cost }
      requested_cost = data_by_type.sum { |_, cost, _, _, _| cost }
      [
        '',
        NumberTo.pounds(requested_cost),
        NumberTo.pounds(allowed_cost),
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
          letter_or_call.provider_requested_amount_inc_vat,
          nil,
          letter_or_call.caseworker_amount_inc_vat,
          nil
        ]
      end
    end
  end
end
