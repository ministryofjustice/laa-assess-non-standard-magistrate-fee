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
        @submission.data['submitter']['email']
      end

      protected

      def defendant
        @submission.data['defendant']
      end

      def defendant_name
        "#{defendant['first_name']} #{defendant['last_name']}"
      end

      def maat_id
        defendant['maat']
      end

      def case_reference
        @submission.data['laa_reference']
      end

      def ufn
        @submission.data['ufn']
      end

      def feedback_url
        Rails.configuration.x.contact.feedback_url
      end
    end
  end
end
