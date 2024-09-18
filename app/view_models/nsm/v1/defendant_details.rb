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
        defendant_rows.flatten.compact
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

      def main_defendant_value
        if main_defendant_maat.present?
          multiline_text("#{main_defendant_name}\n#{main_defendant_maat}")
        else
          main_defendant_name
        end
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
          multiline_text("#{construct_name(defendant)}\n#{defendant['maat']}")
        else
          construct_name(defendant)
        end
      end
    end
  end
end
