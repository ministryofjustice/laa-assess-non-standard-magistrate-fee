# frozen_string_literal: true

module PriorAuthority
  module Messages
    class Base
      include ActionView::Helpers::OutputSafetyHelper

      def initialize(submission)
        @submission = submission.becomes(PriorAuthorityApplication)
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

      def service_required
        application_summary.service_name
      end

      def service_provider_details
        quote = application_details.primary_quote
        [quote.contact_full_name, quote.organisation, quote.town, quote.postcode].compact.join(', ')
      end

      private

      def application_summary
        @application_summary ||= BaseViewModel.build(:application_summary, @submission)
      end

      def application_details
        @application_details ||= BaseViewModel.build(:application_details, @submission)
      end

      def decision
        @decision ||= BaseViewModel.build(:decision, @submission)
      end
    end
  end
end
