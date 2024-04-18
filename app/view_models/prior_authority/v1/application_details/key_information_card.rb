module PriorAuthority
  module V1
    class ApplicationDetails
      class KeyInformationCard < BaseCard
        CARD_ROWS = %i[main_offence ufn primary_quote_postcode].freeze

        delegate :main_offence, to: :application_details

        def ufn
          application_details.ufn if application_details.prison_law
        end

        def primary_quote_postcode
          application_details.primary_quote.postcode
        end
      end
    end
  end
end
