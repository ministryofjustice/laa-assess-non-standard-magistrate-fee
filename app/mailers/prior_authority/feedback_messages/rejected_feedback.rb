# frozen_string_literal: true

module PriorAuthority
  module FeedbackMessages
    class RejectedFeedback < FeedbackBase
      def template
        '81e9222e-c6bd-4fba-91ff-d90d3d61af87'
      end

      def contents
        {
          laa_case_reference: case_reference,
          ufn: ufn,
          defendant_name: defendant_name,
          application_total: application_total,
          caseworker_decision_explanation: comments,
          date: DateTime.now.strftime('%d %B %Y'),
        }
      end
    end
  end
end
