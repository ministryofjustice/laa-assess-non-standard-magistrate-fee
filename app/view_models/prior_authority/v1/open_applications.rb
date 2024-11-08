module PriorAuthority
  module V1
    class OpenApplications < SearchResults
      def search_params
        super.merge(
          application_type: 'crm4',
          status_with_assignment: %w[not_assigned in_progress sent_back provider_updated]
        )
      end
    end
  end
end
