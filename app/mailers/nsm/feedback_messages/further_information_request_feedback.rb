# frozen_string_literal: true

module Nsm
  module FeedbackMessages
    class FurtherInformationRequestFeedback < FeedbackBase
      def template
        if FeatureFlags.nsm_rfi_loop.enabled?
          '632fc896-8019-4308-a091-67f593700f32'
        else
          '9ecdec30-83d7-468d-bec2-cf770a2c9828'
        end
      end

      def contents
        {
          laa_case_reference: case_reference,
          ufn: ufn,
          main_defendant_name: defendant_name,
          defendant_reference: defendant_reference_string,
          claim_total: claim_total,
          date_to_respond_by: date_to_respond_by,
          caseworker_information_requested: @comment,
          date: DateTime.now.to_fs(:stamp),
        }
      end

      def date_to_respond_by
        if FeatureFlags.nsm_rfi_loop.enabled?
          DateTime.parse(@submission.data['resubmission_deadline']).to_fs(:stamp)
        else
          7.days.from_now.to_fs(:stamp)
        end
      end
    end
  end
end
