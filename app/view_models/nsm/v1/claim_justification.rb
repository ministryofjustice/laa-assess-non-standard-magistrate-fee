module Nsm
  module V1
    class ClaimJustification < BaseViewModel
      attribute :reasons_for_claim, :translated_array, scope: 'nsm.reason_for_claim'
      attribute :reason_for_claim_other_details

      def key
        'claim_justification'
      end

      def title
        I18n.t(".nsm.claim_details.#{key}.title")
      end

      def reasons_for_claim_list
        reasons = reasons_for_claim.map(&:to_s)
        sanitize(reasons.join('<br>'), tags: %w[br])
      end

      def data
        [
          {
            title: I18n.t(".nsm.claim_details.#{key}.reasons_for_claim"),
            value: reasons_for_claim_list
          },
          (
            if reasons_for_claim.detect { _1.value == 'other' }
              {
                title: I18n.t(".nsm.claim_details.#{key}.other_details"),
                value: reason_for_claim_other_details
              }
            end
          )
        ].compact
      end

      def rows
        { title:, data: }
      end
    end
  end
end
