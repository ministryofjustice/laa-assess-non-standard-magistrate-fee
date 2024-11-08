module PriorAuthority
  module V1
    class ClosedApplications < SearchResults
      def search_params
        super.merge(
          application_type: 'crm4',
          status_with_assignment: %w[granted auto_grant rejected part_grant expired]
        )
      end
    end
  end
end
