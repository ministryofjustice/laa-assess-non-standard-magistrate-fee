# frozen_string_literal: true

class RejectedFeedback < FeedbackBase
  def template
    '7e807120-b661-452c-95a6-1ae46f411cfe'
  end

  def contents
    {
      LAA_case_reference: case_reference,
      UFN: ufn,
      main_defendant_name: defendant_name,
      maat_id: maat_id,
      claim_total: '',
      caseworker_decision_explanation: '',
      date: DateTime.now.strftime('%d %B %Y'),
      feedback_url: feedback_url
    }
  end

  def recipient
    @claim.submitter.email
  end
end
