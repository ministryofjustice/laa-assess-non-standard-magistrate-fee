module Nsm
  module V1
    class AdditionalFeesSummary < BaseViewModel
      attribute :submission

      def rows
        @rows ||= submission.additional_fees.map do |type, details|
          # TODO: CRM457-2306 ensure adjustment comment
          # attribute is instantiated on AdditionalFee instance
          # so that any_adjustments? works as expected
          AdditionalFee.new({ type: }.merge(details))
        end
      end
    end
  end
end
