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
          caseworker_information_requested: comments,
          date: DateTime.now.strftime('%d %B %Y'),
        }
      end

      protected

      def comments
        [incorrect_information_explanation, further_information_explanation].compact_blank.join("\n\n")
      end

      def incorrect_information_explanation
        @submission.data['incorrect_information_explanation']
      end

      def further_information_explanation
        @submission.data['further_information_explanation']
      end
    end
  end
end
