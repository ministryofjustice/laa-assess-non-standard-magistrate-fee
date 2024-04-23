module PriorAuthority
  module V1
    class ApplicationDetails
      class NoAlternativeQuotesCard < BaseCard
        CARD_ROWS = %i[no_alternative_quote_reason].freeze

        def no_alternative_quote_reason
          simple_format(application_details.no_alternative_quote_reason)
        end
      end
    end
  end
end
