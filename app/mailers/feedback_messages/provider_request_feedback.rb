# frozen_string_literal: true

module FeedbackMessages
  class ProviderRequestFeedback < FeedbackBase
    def template
      'bfd28bd8-b9d8-4b18-8ce0-3fb763123573'
    end

    def contents
      {
        laa_case_reference: case_reference,
        ufn: ufn,
        main_defendant_name: defendant_name,
        defendant_reference: defendant_reference_string,
        claim_total: claim_total,
        date: DateTime.now.strftime('%d %B %Y'),
        feedback_url: feedback_url
      }
    end
  end
end
