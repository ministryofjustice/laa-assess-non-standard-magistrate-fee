module Nsm
  module V1
    class YourClaims < SearchResults
      attribute :current_user
      def search_params
        super.except('current_user').merge(
          application_type: 'crm7',
          status_with_assignment: %w[in_progress sent_back provider_updated],
          current_caseworker_id: current_user.id
        )
      end
    end
  end
end
