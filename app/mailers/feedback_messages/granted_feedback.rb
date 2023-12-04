# frozen_string_literal: true

module FeedbackMessages
  class GrantedFeedback < FeedbackBase
    def template
      '80c0dcd2-597b-4c82-8c94-f6e26af71a40'
    end

    def contents
      {
        laa_case_reference: case_reference,
        ufn: ufn,
        main_defendant_name: defendant_name,
        maat_id: maat_id,
        claim_total: '',
        date: DateTime.now.strftime('%d %B %Y'),
        feedback_url: feedback_url
      }
    end

    def recipient
      @claim.data['submitter']['email']
    end
  end
end
