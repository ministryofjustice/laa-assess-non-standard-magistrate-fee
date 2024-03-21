# frozen_string_literal: true

module PriorAuthority
  module FeedbackMessages
    class FeedbackBase
      def initialize(submission)
        @submission = submission
      end

      def template
        raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
      end

      def contents
        raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
      end

      def recipient
        @submission.data['solicitor']['contact_email']
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
        application_summary.formatted_original_total_cost
      end

      def comments
        decision.comments
      end

      def feedback_url
        Rails.configuration.x.contact.feedback_url
      end

      private

      def application_summary
        @application_summary ||= BaseViewModel.build(:application_summary, @submission)
      end

      def decision
        @decision ||= BaseViewModel.build(:decision, @submission)
      end
    end
  end
end
