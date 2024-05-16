module PriorAuthority
  module V1
    class TableRow < BaseViewModel
      include SubmissionTagHelper

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

      def date_updated_str
        submission.updated_at.to_fs(:stamp)
      end

      def service_name
        I18n.t(submission.data['service_type'], scope: 'prior_authority.service_types')
      end

      def caseworker
        submission.assignments.first&.display_name || I18n.t('prior_authority.applications.not_assigned')
      end

      def status
        submission_state_tag(submission)
      end
    end
  end
end
