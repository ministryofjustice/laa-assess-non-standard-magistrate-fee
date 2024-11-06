module Nsm
  module V1
    class OpenClaims < SearchResults
      def search_params
        super.merge(
          application_type: 'crm7',
          status_with_assignment: %w[not_assigned in_progress sent_back provider_updated]
        )
      end
    end
  end
end
