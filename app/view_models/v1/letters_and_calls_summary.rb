module V1
  class LettersAndCallsSummary < BaseViewModel
    attribute :letters_and_calls

    def table_fields
      data_by_type.map do |letter_and_call_type, total_cost|
        [
          letter_and_call_type,
          NumberTo.pounds(total_cost)
        ]
      end
    end

    def summed_fields
      total_cost = data_by_type.sum { |_, cost| cost }
      [
        NumberTo.pounds(total_cost)
      ]
    end

    def summary_row
      total_number_of_letters_and_calls = letters_and_calls.sum { |item| item['count'] }
      total_cost = data_by_type.sum { |_, cost| cost }
      adjusted_cost = '#pending#'
      [
        total_number_of_letters_and_calls.to_s,
        '-',
        NumberTo.pounds(total_cost),
        '-',
        adjusted_cost
      ]
    end

    private

    def letters_or_calls
      @letters_or_calls ||=
        letters_and_calls.map { |letter_or_call| LetterAndCall.build_self(letter_or_call) }
    end

    def data_by_type
      @data_by_type ||=
        letters_or_calls.map do |letter_or_call|
          [
            letter_or_call.type.to_s,
            letter_or_call.provider_requested_amount
          ]
        end
    end
  end
end
