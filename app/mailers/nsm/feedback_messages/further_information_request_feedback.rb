# frozen_string_literal: true

module Nsm
  module FeedbackMessages
    class FurtherInformationRequestFeedback < FeedbackBase
      def template
        '9ecdec30-83d7-468d-bec2-cf770a2c9828'
      end

      def contents
        {
          laa_case_reference: case_reference,
          ufn: ufn,
          main_defendant_name: defendant_name,
          defendant_reference: defendant_reference_string,
          claim_total: claim_total,
          date_to_respond_by: 7.days.from_now.to_fs(:stamp),
          caseworker_information_requested: @comment,
          date: DateTime.now.to_fs(:stamp),
        }
      end
    end
  end
end
