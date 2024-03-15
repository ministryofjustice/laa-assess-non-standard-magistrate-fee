# frozen_string_literal: true

module PriorAuthority
  module FeedbackMessages
    class GrantedFeedback < FeedbackBase
      def template
        'd4f3da60-4da5-423e-bc93-d9235ff01a7b'
      end

      def contents
        {
          laa_case_reference: case_reference,
          ufn: ufn,
          defendant_name: defendant_name,
          application_total: application_total,
          date: DateTime.now.strftime('%d %B %Y'),
          feedback_url: feedback_url
        }
      end
    end
  end
end
