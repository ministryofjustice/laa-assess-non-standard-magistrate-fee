module V1
  class LettersAndCallsSummary < BaseViewModel
    attribute :letters_and_calls

    def summary_row
      [
        rows.sum(&:count).to_s,
        '-',
        NumberTo.pounds(rows.sum(&:provider_requested_amount)),
        '-',
        NumberTo.pounds(rows.sum(&:allowed_amount))
      ]
    end

    def rows
      @rows ||= letters_and_calls.map do |data|
        LetterAndCall.build_self(data)
      end
    end
  end
end
