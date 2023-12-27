# frozen_string_literal: true

module FeedbackMessages
  class FeedbackBase
    def initialize(claim, comment = nil)
      @claim = claim
      @comment = comment
    end

    def template
      raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
    end

    def contents
      raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
    end

    def recipient
      raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
    end

    protected

    def main_defendant
      @claim.data['defendants'].find { |defendant| defendant['main'] == true }
    end

    def defendant_name
      main_defendant['full_name']
    end

    def maat_id
      main_defendant['maat']
    end

    def case_reference
      @claim.data['laa_reference']
    end

    def ufn
      @claim.data['ufn']
    end

    def claim_total
      @claim.data['submitted_total_inc_vat'] || @claim.data['submitted_total']
    end

    def feedback_url
      Rails.configuration.x.contact.feedback_url
    end
  end
end
