# frozen_string_literal: true

module PriorAuthority
  module FeedbackMessages
    class FeedbackBase
      def initialize(submission, comment = '')
        @submission = submission
        @comment = comment
      end

      def template
        raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
      end

      def contents
        raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
      end

      def recipient
        @submission.data['provider']['email']
      end

      protected

      def defendant
        @submission.data['defendant']
      end

      def defendant_name
        "#{defendant['first_name']} #{defendant['last_name']}"
      end

      def case_reference
        @submission.data['laa_reference']
      end

      def ufn
        @submission.data['ufn']
      end

      def application_total
        'TODO'
        # @submission.data['submitted_total_inc_vat'] || @submission.data['submitted_total'] || 0
      end

      def feedback_url
        Rails.configuration.x.contact.feedback_url
      end
    end
  end
end
