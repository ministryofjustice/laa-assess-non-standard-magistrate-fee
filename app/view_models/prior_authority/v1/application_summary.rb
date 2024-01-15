module PriorAuthority
  module V1
    class ApplicationSummary < BaseViewModel
      attribute :laa_reference
      attribute :firm_name
      attribute :submitted_total
      attribute :client_name
      attribute :application

      def date_created_str
        I18n.l(application.created_at, format: '%-d %b %Y')
      end
    end
  end
end
