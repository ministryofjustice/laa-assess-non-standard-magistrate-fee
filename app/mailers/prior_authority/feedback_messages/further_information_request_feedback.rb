# frozen_string_literal: true

module PriorAuthority
  module FeedbackMessages
    class FurtherInformationRequestFeedback < FeedbackBase
      def template
        'c8abf9ee-5cfe-44ab-9253-72111b7a35ba'
      end

      def contents
        {
          laa_case_reference: case_reference,
          ufn: ufn,
          defendant_name: defendant_name,
          application_total: application_total,
          date_to_respond_by: 14.days.from_now.strftime('%d %B %Y'),
          caseworker_information_requested: @comment,
          date: DateTime.now.strftime('%d %B %Y'),
          feedback_url: feedback_url
        }
      end
    end
  end
end
