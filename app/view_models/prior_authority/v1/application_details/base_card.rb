module PriorAuthority
  module V1
    class ApplicationDetails
      class BaseCard
        include ActionView::Helpers::TagHelper
        include ActionView::Helpers::OutputSafetyHelper
        include ActionView::Helpers::UrlHelper

        CARD_ROWS = [].freeze
        TABLE_ROWS = [].freeze

        attr_reader :application_details

        def initialize(application_details)
          @application_details = application_details
        end

        def card_rows
          self.class::CARD_ROWS.filter_map do |key|
            value = send(key)

            if value
              {
                key: { text: I18n.t("prior_authority.application_details.#{key}") },
                value: { text: value }
              }
            end
          end
        end

        private

        def url_helpers
          Rails.application.routes.url_helpers
        end
      end
    end
  end
end
