module V1
  class LettersAndCallsSummary < BaseViewModel
    attribute :letters_and_calls
    attribute :claim

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
      @rows ||= LetterAndCall.build_from_hash(LetterAndCall, letters_and_calls, claim)
    end
  end
end
