module Nsm
  module V1
    class ClosedClaims < SearchResults
      def search_params
        super.merge(
          application_type: 'crm7',
          status_with_assignment: %w[rejected granted part_grant expired]
        )
      end
    end
  end
end
