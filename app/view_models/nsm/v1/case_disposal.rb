module Nsm
  module V1
    class CaseDisposal < BaseViewModel
      attribute :plea, :translated, scope: 'nsm.plea'
      attribute :plea_category, :translated, scope: 'nsm.plea_category'

      def key
        'case_disposal'
      end

      def title
        I18n.t(".nsm.claim_details.#{key}.title")
      end

      def data
        [
          {
            title: plea_category.to_s,
            value:  plea.to_s
          }
        ]
      end

      def rows
        { title:, data: }
      end
    end
  end
end
