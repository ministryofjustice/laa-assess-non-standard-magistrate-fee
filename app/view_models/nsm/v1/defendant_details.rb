module Nsm
  module V1
    class DefendantDetails < BaseViewModel
      attribute :defendants

      def key
        'defendant_details'
      end

      def title
        I18n.t(".nsm.claim_details.#{key}.title")
      end

      def data
        defendant_rows.flatten
      end

      def defendant_rows
        main_defendant_rows + additional_defendant_rows
      end

      def main_defendant_name
        main_defendant = defendants.detect { |defendant| defendant['main'] }
        construct_name(main_defendant)
      end

      def main_defendant_maat
        main_defendant = defendants.detect { |defendant| defendant['main'] }
        main_defendant['maat']
      end

      def additional_defendants
        defendants.reject { |defendant| defendant['main'] == true }
      end

      def main_defendant_rows
        [
          {
            title:  I18n.t(".nsm.claim_details.#{key}.main_defendant_name"),
            value: main_defendant_name
          },
          {
            title: I18n.t(".nsm.claim_details.#{key}.main_defendant_maat"),
            value: main_defendant_maat
          }
        ]
      end

      def additional_defendant_rows
        additional_defendants.map.with_index do |defendant, index|
          [
            {
              title: I18n.t(".nsm.claim_details.#{key}.defendant_name", count: index + 1),
              value: construct_name(defendant)
            },
            {
              title: I18n.t(".nsm.claim_details.#{key}.defendant_maat", count: index + 1),
              value: defendant['maat']
            }
          ]
        end
      end

      def rows
        { title:, data: }
      end
    end
  end
end
