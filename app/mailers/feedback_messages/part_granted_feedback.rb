# frozen_string_literal: true

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
        maat_id: maat_id,
        claim_total: '',
        part_grant_total: '',
        caseworker_decision_explanation: '',
        date: DateTime.now.strftime('%d %B %Y'),
        feedback_url: feedback_url
      }
    end

    def recipient
      @claim.data['submitter']['email']
    end
  end
end
