module Nsm
  module V1
    class TableRow < BaseViewModel
      include SubmissionTagHelper

      attribute :laa_reference
      attribute :defendants
      attribute :firm_office
      attribute :submission
      attribute :risk
      delegate :last_updated_at, to: :submission

      def main_defendant_name
        main_defendant = defendants.detect { |defendant| defendant['main'] }
        main_defendant ? construct_name(main_defendant) : ''
      end

      def firm_name
        firm_office['name']
      end

      def date_updated
        last_updated_at.to_fs(:stamp)
      end

      def case_worker_name
        submission.assignments.first&.display_name || I18n.t('nsm.claims.table.unassigned')
      end

      def state_tag
        submission_state_tag(submission)
      end

      def risk_name
        I18n.t("nsm.claims.table.risk.#{risk}")
      end

      delegate :id, to: :submission
    end
  end
end
