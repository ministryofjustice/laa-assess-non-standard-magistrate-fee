module PriorAuthority
  module V1
    class ApplicationSummary < BaseViewModel
      attribute :laa_reference, :string
      attribute :firm_office
      attribute :quotes
      attribute :additional_costs
      attribute :defendant
      attribute :service_type, :string
      attribute :submission

      delegate :id, to: :submission

      def client_name
        "#{defendant['first_name']} #{defendant['last_name']}"
      end

      def firm_name
        firm_office['name']
      end

      def date_created_str
        I18n.l(submission.created_at, format: '%-d %b %Y')
      end

      def primary_quote
        @primary_quote ||= Quote.new(quotes.find { _1['primary'] }.merge(additional_cost_json: additional_costs))
      end

      def formatted_total_cost
        NumberTo.pounds(primary_quote.total_cost)
      end
    end
  end
end
