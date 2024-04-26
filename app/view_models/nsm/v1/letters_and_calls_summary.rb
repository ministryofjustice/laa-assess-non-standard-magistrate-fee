module Nsm
  module V1
    class LettersAndCallsSummary < BaseViewModel
      attribute :submission

      def rows
        @rows ||= BaseViewModel.build(:letter_and_call, submission, 'letters_and_calls')
      end

      def uplift?
        rows.any? { |row| row.uplift&.positive? }
      end
    end
  end
end
