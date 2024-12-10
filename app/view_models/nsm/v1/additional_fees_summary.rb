module Nsm
  module V1
    class AdditionalFeesSummary < BaseViewModel
      attribute :submission

      def rows
        @rows ||= submission.additional_fees.except(*excluded).map do |type, details|
          model = BaseViewModel.build(type, submission)
          model.assign_attributes(details)
          model
        end
      end

      private

      def excluded
        [:total]
      end
    end
  end
end
