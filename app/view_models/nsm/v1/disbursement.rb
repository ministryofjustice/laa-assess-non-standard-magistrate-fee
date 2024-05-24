module Nsm
  module V1
    class Disbursement < BaseWithAdjustments
      LINKED_TYPE = 'disbursements'.freeze

      attribute :disbursement_type, :translated
      attribute :other_type, :translated
      adjustable_attribute :miles, :decimal, precision: 10, scale: 3
      attribute :pricing, :decimal, precision: 10, scale: 2
      adjustable_attribute :total_cost_without_vat, :decimal, precision: 10, scale: 2
      attribute :vat_rate, :decimal, precision: 3, scale: 2
      attribute :disbursement_date, :date
      attribute :id, :string
      attribute :details, :string
      attribute :prior_authority, :string
      adjustable_attribute :apply_vat, :string
      adjustable_attribute :vat_amount, :decimal, precision: 10, scale: 2

      class << self
        def headers
          [
            t('.item', width: 'govuk-!-width-one-fifth', numeric: false),
            t('.claimed_net'),
            t('.claimed_vat'),
            t('.claimed_gross'),
            t('.allowed_net'),
            t('.allowed_vat'),
            t('.allowed_gross'),
            t('.action')
          ]
        end

        private

        def t(key, width: nil, numeric: true)
          {
            text: I18n.t("nsm.disbursements.index.#{key}"),
            numeric: numeric,
            width: width
          }
        end
      end

      def provider_requested_total_cost
        original_total_cost_without_vat + original_vat_amount
      end

      def caseworker_total_cost
        total_cost_without_vat + vat_amount
      end

      def form_attributes
        attributes.slice('total_cost_without_vat', 'miles', 'apply_vat', 'vat_rate').merge(
          'explanation' => adjustment_comment
        )
      end

      # rubocop:disable Metrics/AbcSize
      def disbursement_fields
        table_fields = {}
        table_fields[:date] = disbursement_date.strftime('%d %b %Y')
        table_fields[:type] = type_name.capitalize
        table_fields[:miles] = miles.to_s if miles.present?
        table_fields[:details] = details.capitalize
        table_fields[:prior_authority] = prior_authority.capitalize
        table_fields[:vat] = format_vat_rate(vat_rate)
        table_fields[:total] = NumberTo.pounds(provider_requested_total_cost)

        table_fields
      end
      # rubocop:enable Metrics/AbcSize

      def format_vat_rate(rate)
        "#{(rate * 100).to_i}%"
      end

      def type_name
        other_type.to_s.presence || disbursement_type.to_s
      end

      def table_fields
        [
          type_name,
          format(original_total_cost_without_vat),
          format(original_vat_amount),
          format(provider_requested_total_cost),
          format(any_adjustments? && total_cost_without_vat),
          format(any_adjustments? && vat_amount),
          format(any_adjustments? && caseworker_total_cost)
        ]
      end

      def format(value)
        return '' if value.nil? || value == false

        { text: NumberTo.pounds(value), numeric: true }
      end

      def changed?
        original_total_cost_without_vat != total_cost_without_vat
      end
    end
  end
end
