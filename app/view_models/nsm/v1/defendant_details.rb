module Nsm
  module V1
    class DefendantDetails < BaseViewModel
      include ActionView::Helpers::TagHelper
      include ActionView::Helpers::OutputSafetyHelper

      attribute :defendants

      def key
        'defendant_details'
      end

      def title
        I18n.t(".nsm.claim_details.#{key}.title")
      end

      def data
        defendant_rows.flatten.compact
      end

      def defendant_rows
        main_defendant_rows + additional_defendant_rows
      end

      def main_defendant_value
        construct_value(defendants.find { _1['main'] })
      end

      def additional_defendants
        defendants.reject { |defendant| defendant['main'] == true }
      end

      def main_defendant_rows
        [
          {
            title:  I18n.t(".nsm.claim_details.#{key}.main_defendant"),
            value: main_defendant_value
          }
        ]
      end

      def additional_defendant_rows
        additional_defendants.map.with_index do |defendant, index|
          [
            {
              title: I18n.t(".nsm.claim_details.#{key}.additional_defendant", count: index + 2),
              value: construct_value(defendant)
            }
          ]
        end
      end

      def rows
        { title:, data: }
      end

      private

      def construct_value(defendant)
        if defendant['maat'].present?
          safe_join([construct_name(defendant), tag.br, defendant['maat']])
        else
          construct_name(defendant)
        end
      end
    end
  end
end
