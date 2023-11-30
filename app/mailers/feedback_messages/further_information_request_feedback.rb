# frozen_string_literal: true

module FeedbackMessages
  class FurtherInformationRequestFeedback < FeedbackBase
    def template
      '9ecdec30-83d7-468d-bec2-cf770a2c9828'
    end

    def contents
      {
        LAA_case_reference: case_reference,
        UFN: ufn,
        main_defendant_name: defendant_name,
        maat_id: maat_id,
        claim_total: '',
        date_to_respond_by: '',
        caseworker_information_requested: '',
        date: DateTime.now.strftime('%d %B %Y'),
        feedback_url: feedback_url
      }
    end

    def recipient
      @claim.submitter.email
    end
  end
end
