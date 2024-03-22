# frozen_string_literal: true

module PriorAuthority
  module FeedbackMessages
    class PartGrantedFeedback < FeedbackBase
      def template
        '97c0245f-9fec-4ec1-98cc-c9d392a81254'
      end

      def contents
        {
          laa_case_reference: case_reference,
          ufn: ufn,
          defendant_name: defendant_name,
          application_total: application_total,
          part_grant_total: adjusted_total,
          caseworker_decision_explanation: comments,
          date: DateTime.now.strftime('%d %B %Y'),
        }
      end

      def adjusted_total
        application_summary.formatted_total_cost
      end
    end
  end
end
