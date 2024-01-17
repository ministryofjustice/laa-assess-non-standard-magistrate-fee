# frozen_string_literal: true

module FeedbackMessages
  class FeedbackBase
    def initialize(claim, comment = '')
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
      @claim.data['defendants'].find { _1['main'] }
    end

    def defendant_name
      main_defendant['full_name']
    end

    def maat_id
      main_defendant['maat']
    end

    def cntp_order
      @claim.data['cntp_order']
    end

    # Markdown conditionals do not allow to format the string nicely so formatting here.
    def defendant_reference_string
      if maat_id.nil?
        "Client's CNTP number: #{cntp_order}"
      else
        "MAAT ID: #{maat_id}"
      end
    end

    def case_reference
      @claim.data['laa_reference']
    end

    def ufn
      @claim.data['ufn']
    end

    def claim_total
      @claim.data['submitted_total_inc_vat'] || @claim.data['submitted_total'] || 0
    end

    def feedback_url
      Rails.configuration.x.contact.feedback_url
    end
  end
end
