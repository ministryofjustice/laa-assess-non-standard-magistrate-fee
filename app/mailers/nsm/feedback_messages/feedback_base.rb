# frozen_string_literal: true

module Nsm
  module FeedbackMessages
    class FeedbackBase
      include NameConstructable

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
        @submission.data['solicitor']['contact_email'].presence || @submission.data['submitter']['email']
      end

      protected

      def main_defendant
        @submission.data['defendants'].find { _1['main'] }
      end

      def defendant_name
        construct_name(main_defendant)
      end

      def maat_id
        main_defendant['maat']
      end

      def cntp_order
        @submission.data['cntp_order']
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
        @submission.data['laa_reference']
      end

      def ufn
        @submission.data['ufn']
      end

      def claim_total
        @submission.formatted_claimed_total
      end
    end
  end
end
