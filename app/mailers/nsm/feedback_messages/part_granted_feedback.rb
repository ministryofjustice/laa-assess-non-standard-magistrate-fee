# frozen_string_literal: true

module Nsm
  module FeedbackMessages
    class PartGrantedFeedback < FeedbackBase
      def template
        '9df38f19-f76b-42f9-a4e1-da36a65d6aca'
      end

      def contents
        {
          laa_case_reference: case_reference,
          ufn: ufn,
          main_defendant_name: defendant_name,
          defendant_reference: defendant_reference_string,
          claim_total: claim_total,
          part_grant_total: adjusted_total,
          caseworker_decision_explanation: @comment,
          date: DateTime.now.strftime('%d %B %Y'),
        }
      end

      def adjusted_total
        @submission.data['adjusted_total_inc_vat'] || @submission.data['adjusted_total'] || 0
      end
    end
  end
end
