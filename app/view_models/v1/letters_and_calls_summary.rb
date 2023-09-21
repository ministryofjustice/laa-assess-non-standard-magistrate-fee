module V1
  class LettersAndCallsSummary < BaseViewModel
    attribute :letters_and_calls

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

    def data_by_type
      @data_by_type ||=
        letters_and_calls.map do |hash|
          letter_or_call = LetterAndCall.build_self(hash)
          [
            letter_or_call.type.to_s,
            letter_or_call.provider_requested_amount
          ]
        end
    end
  end
end
