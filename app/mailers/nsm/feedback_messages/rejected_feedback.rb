# frozen_string_literal: true

module Nsm
  module FeedbackMessages
    class RejectedFeedback < FeedbackBase
      def template
        '7e807120-b661-452c-95a6-1ae46f411cfe'
      end

      def contents
        {
          laa_case_reference: case_reference,
          ufn: ufn,
          main_defendant_name: defendant_name,
          defendant_reference: defendant_reference_string,
          claim_total: claim_total,
          caseworker_decision_explanation: @comment,
          date: DateTime.now.strftime('%d %B %Y'),
          feedback_url: feedback_url
        }
      end
    end
  end
end
