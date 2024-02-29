module PriorAuthority
  module V1
    class ApplicationDetails
      class AlternativeQuoteCard < PrimaryQuoteCard
        CARD_ROWS = %i[
          service_details
          quote_upload
          additional_items
        ].freeze

        delegate :additional_cost_list, :formatted_total_cost, to: :quote

        def initialize(application_details, alternative_quote)
          @alternative_quote = alternative_quote
          super(application_details)
        end

        def quote
          @alternative_quote
        end

        def additional_items
          return I18n.t('prior_authority.application_details.none') if additional_cost_list.blank?

          safe_join(
            additional_cost_list.split("\n").map { [_1, tag.br] }.flatten
          )
        end

        def additional_label
          I18n.t('prior_authority.application_details.additional')
        end

        def total_label
          I18n.t('prior_authority.application_details.total_cost')
        end

        def table_rows
          rows = [base_row]

          rows << travel_row if any_travel_costs?
          rows << additional_cost_row if any_additional_costs?

          rows + [footer_row]
        end

        def any_travel_costs?
          quote.travel_costs.positive? || primary_quote.travel_costs.positive?
        end

        def any_additional_costs?
          quote.total_additional_costs.positive? || primary_quote.total_additional_costs.positive?
        end

        def base_row
          [service_label, formatted_base_cost, primary_quote.formatted_base_cost]
        end

        def travel_row
          [travel_label, formatted_travel_cost, primary_quote.formatted_travel_cost]
        end

        def additional_cost_row
          [additional_label, quote.formatted_additional_costs, primary_quote.formatted_additional_costs]
        end

        def footer_row
          [tag.strong(total_label), tag.strong(formatted_total_cost), tag.strong(formatted_primary_quote_total_cost)]
        end

        def formatted_primary_quote_total_cost
          primary_quote.formatted_total_cost
        end
      end
    end
  end
end
