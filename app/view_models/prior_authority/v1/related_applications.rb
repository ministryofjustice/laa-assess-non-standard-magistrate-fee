module PriorAuthority
  module V1
    class RelatedApplications < SearchResults
      PER_PAGE = 10

      attribute :current_application_summary

      def search_params
        super.except('current_application_summary').merge(
          application_type: 'crm4',
          id_to_exclude: current_application_summary.id,
          query: current_application_summary.ufn,
          account_number: current_application_summary.firm_account_number
        )
      end
    end
  end
end
