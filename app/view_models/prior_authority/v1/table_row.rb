module PriorAuthority
  module V1
    class TableRow < BaseViewModel
      include PriorAuthorityTagHelper

      attribute :laa_reference, :string
      attribute :firm_office
      attribute :defendant
      attribute :submission

      delegate :id, to: :submission

      def firm_name
        firm_office['name']
      end

      def client_name
        "#{defendant['first_name']} #{defendant['last_name']}"
      end

      def date_created_str
        submission.created_at.to_fs(:stamp)
      end

      def date_assessed_str
        submission.updated_at.to_fs(:stamp)
      end
      alias date_updated_str date_assessed_str

      def service_name
        I18n.t(submission.data['service_type'], scope: 'prior_authority.service_types')
      end

      def caseworker
        submission.assignments.first&.display_name || I18n.t('prior_authority.applications.not_assigned')
      end

      def status
        prior_authority_state_tag(submission)
      end
    end
  end
end
