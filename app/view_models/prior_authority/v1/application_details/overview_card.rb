module PriorAuthority
  module V1
    class ApplicationDetails
      class OverviewCard < BaseCard
        CARD_ROWS = %i[laa_reference ufn prison_law_string].freeze

        delegate :laa_reference, :ufn, :prison_law, to: :application_details

        def prison_law_string
          I18n.t("shared.#{prison_law}")
        end
      end
    end
  end
end
