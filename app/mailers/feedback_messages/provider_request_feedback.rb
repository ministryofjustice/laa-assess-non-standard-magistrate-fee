# frozen_string_literal: true

class ProviderRequestFeedback < FeedbackBase
  def template
    'bfd28bd8-b9d8-4b18-8ce0-3fb763123573'
  end

  def contents
    {
      LAA_case_reference: case_reference,
      UFN: ufn,
      main_defendant_name: defendant_name,
      maat_id: maat_id,
      claim_total: '',
      date: DateTime.now.strftime('%d %B %Y'),
      feedback_url: feedback_url
    }
  end

  def recipient
    @claim.submitter.email
  end
end
