# frozen_string_literal: true

module FeedbackMessages
  class FeedbackBase
    def initialize(claim)
      @claim = claim
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
      @claim.defendants.find { |defendant| defendant.main == true }
    end

    def defendant_name
      main_defendant.full_name
    end

    def maat_id
      main_defendant.maat
    end

    def case_reference
      @claim.laa_reference
    end

    def ufn
      @claim.ufn
    end

    def feedback_url
      Rails.configuration.x.contact.feedback_url
    end
  end
end
