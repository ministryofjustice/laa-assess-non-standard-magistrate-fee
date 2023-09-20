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
      [

      ]
    end

    private

    def data_by_type
      @data_by_type ||=
        letters_and_calls
        .map do |letter_and_call|
          letter_or_call = LetterAndCall.build_self(letter_and_call)
          [
            letter_or_call.type.to_s,
            letter_or_call.provider_requested_amount
          ]
        end
    end
  end
end
