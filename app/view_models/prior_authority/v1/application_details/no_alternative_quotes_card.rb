module PriorAuthority
  module V1
    class ApplicationDetails
      class NoAlternativeQuotesCard < BaseCard
        CARD_ROWS = %i[no_alternative_quote_reason].freeze

        delegate :no_alternative_quote_reason, to: :application_details
      end
    end
  end
end
