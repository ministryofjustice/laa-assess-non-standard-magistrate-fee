module PriorAuthority
  module V1
    class ApplicationDetails
      class PrimaryQuoteCard < BaseCard
        CARD_ROWS = %i[
          service_name
          service_details
          quote_upload
          ordered_by_court
          related_to_post_mortem
          existing_prior_authority_granted
          travel_cost_reason
        ].freeze

        def table_rows
          rows = [[service_label, base_units, base_cost_per_unit, formatted_base_cost]]

          rows << [travel_label, travel_units, travel_cost_per_unit, formatted_travel_cost] if quote.travel_costs.positive?

          rows + quote.additional_costs.map do |additional_cost|
            additional_cost_row(additional_cost)
          end
        end

        def additional_cost_row(additional_cost)
          [additional_cost.name,
           additional_cost.original_unit_description,
           additional_cost.original_cost_per_unit,
           additional_cost.formatted_total_cost]
        end

        delegate :primary_quote, :service_name, :prior_authority_granted, to: :application_details

        delegate :base_units, :base_cost_per_unit,
                 :travel_units, :travel_cost_per_unit,
                 :formatted_base_cost, :formatted_travel_cost,
                 to: :quote

        def quote
          primary_quote
        end

        def travel_cost_reason
          simple_format(quote.travel_cost_reason) if quote.travel_cost_reason.present?
        end

        def service_label
          I18n.t('prior_authority.application_details.service')
        end

        def travel_label
          I18n.t('prior_authority.application_details.travel')
        end

        def service_details
          safe_join([quote.contact_full_name, tag.br, quote.organisation, ', ', quote.postcode])
        end

        def quote_upload
          return I18n.t('prior_authority.application_details.none') if quote.uploaded_document.file_path.blank?

          link_to(quote.uploaded_document.file_name,
                  url_helpers.prior_authority_download_path(quote.uploaded_document.file_path,
                                                            file_name: quote.uploaded_document.file_name))
        end

        def ordered_by_court
          I18n.t("shared.#{quote.ordered_by_court}") unless quote.ordered_by_court.nil?
        end

        def related_to_post_mortem
          I18n.t("shared.#{quote.related_to_post_mortem}") unless quote.related_to_post_mortem.nil?
        end

        def existing_prior_authority_granted
          I18n.t("shared.#{prior_authority_granted}")
        end
      end
    end
  end
end
