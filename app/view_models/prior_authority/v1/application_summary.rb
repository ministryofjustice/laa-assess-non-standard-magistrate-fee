module PriorAuthority
  module V1
    class ApplicationSummary < BaseViewModel
      attribute :laa_reference
      attribute :firm_name
      attribute :submitted_total
      attribute :client_name
      attribute :submission

      def date_created_str
        I18n.l(submission.created_at, format: '%-d %b %Y')
      end
    end
  end
end
