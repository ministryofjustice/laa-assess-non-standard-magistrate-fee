module PriorAuthority
  module V1
    class ApplicationDetails < ApplicationSummary
      attribute :ufn, :string
      attribute :prison_law, :boolean

      def overview
        rows(:laa_reference, :ufn, :prison_law_string)
      end

      def prison_law_string
        I18n.t("shared.#{prison_law}")
      end

      def primary_quote_rows
        []
      end

      private

      def rows(*keys)
        keys.filter_map do |key|
          value = send(key)

          if value
            {
              key: { text: I18n.t("prior_authority.application_details.#{key}") },
              value: { text: value }
            }
          end
        end
      end
    end
  end
end
