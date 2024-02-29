module PriorAuthority
  module V1
    class ApplicationDetails
      class KeyInformationCard < BaseCard
        CARD_ROWS = %i[main_offence primary_quote_postcode].freeze

        delegate :main_offence, to: :application_details

        def primary_quote_postcode
          application_details.primary_quote.postcode
        end
      end
    end
  end
end
