module Nsm
  module V1
    class AdditionalFeesSummary < BaseViewModel
      attribute :submission

      def rows
        @rows ||= submission.additional_fees.map do |type, details|
          AdditionalFee.new({ type: }.merge(details))
        end
      end
    end
  end
end
