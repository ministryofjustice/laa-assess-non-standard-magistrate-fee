module PriorAuthority
  module V1
    class YourApplications < SearchResults
      attribute :current_user
      def search_params
        super.except('current_user').merge(
          application_type: 'crm4',
          status_with_assignment: %w[in_progress provider_updated],
          current_caseworker_id: current_user.id
        )
      end
    end
  end
end
