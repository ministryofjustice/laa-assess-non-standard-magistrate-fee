# frozen_string_literal: true

module PriorAuthority
  module FeedbackMessages
    class GrantedFeedback < FeedbackBase
      def template
        'd4f3da60-4da5-423e-bc93-d9235ff01a7b'
      end

      def contents
        {
          laa_case_reference: case_reference,
          ufn: ufn,
          defendant_name: defendant_name,
          service_required: service_required,
          service_provider_details: service_provider_details,
          application_total: application_total,
          date: DateTime.now.to_fs(:stamp),
        }
      end
    end
  end
end
