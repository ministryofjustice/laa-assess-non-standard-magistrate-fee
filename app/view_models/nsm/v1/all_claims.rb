module Nsm
  module V1
    class AllClaims < BaseViewModel
      attribute :laa_reference
      attribute :defendants
      attribute :firm_office
      attribute :submission
      delegate :created_at, to: :submission

      def main_defendant_name
        main_defendant = defendants.detect { |defendant| defendant['main'] }
        main_defendant ? construct_name(main_defendant) : ''
      end

      def firm_name
        firm_office['name']
      end

      def date_created
        I18n.l(created_at, format: '%-d %b %Y')
      end

      def case_worker_name
        submission.assignments.first&.display_name || I18n.t('nsm.claims.open.unassigned')
      end

      delegate :id, to: :submission
    end
  end
end
