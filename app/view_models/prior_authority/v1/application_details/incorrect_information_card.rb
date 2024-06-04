module PriorAuthority
  module V1
    class ApplicationDetails
      class IncorrectInformationCard < BaseCard
        CARD_ROWS = %i[
          caseworker
          information_request
          provider_response
        ].freeze

        def initialize(application_details, incorrect_information)
          @incorrect_information = incorrect_information
          super(application_details)
        end

        def caseworker
          User.find(@incorrect_information['caseworker_id']).display_name
        end

        def information_request
          simple_format(@incorrect_information['information_requested'])
        end

        def provider_response
          links = @incorrect_information['sections_changed'].map do |section_name|
            label = section_name.starts_with?('alternative_quote_') ? 'alternative_quote' : section_name
            n = section_name.gsub('alternative_quote_', ''),
            anchor = "##{section_name == 'ufn' ? 'overview' : section_name.tr('_', '-')}"

            tag.li do
              link_to I18n.t("prior_authority.applications.show.updated_field", field: I18n.t("prior_authority.applications.show.updated_fields.#{label}", n: n)),
              anchor, class: "govuk-link--no-visited-state"
            end
          end

          tag.ul class: 'govuk-list' do
            safe_join(links)
          end
        end

        def requested_at_str
          requested_at.to_fs(:stamp)
        end

        def requested_at
          @requested_at ||= Date.parse(@incorrect_information['requested_at'])
        end

        def partial
          'incorrect_information_card'
        end
      end
    end
  end
end
