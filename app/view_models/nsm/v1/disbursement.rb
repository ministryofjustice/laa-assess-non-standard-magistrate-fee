module Nsm
  module V1
    class Disbursement < BaseWithAdjustments
      LINKED_TYPE = 'disbursements'.freeze
      ID_FIELDS = %w[id].freeze
      attribute :disbursement_type, :translated
      attribute :other_type, :translated
      # TODO: import time_period code from provider app
      attribute :miles, :decimal, precision: 10, scale: 3
      attribute :pricing, :decimal, precision: 10, scale: 2
      adjustable_attribute :total_cost_without_vat, :decimal, precision: 10, scale: 2
      attribute :vat_rate, :decimal, precision: 3, scale: 2
      attribute :disbursement_date, :date
      attribute :id, :string
      attribute :details, :string
      attribute :prior_authority, :string
      attribute :apply_vat, :string
      adjustable_attribute :vat_amount, :decimal, precision: 10, scale: 2

      def provider_requested_total_cost
        original_total_cost_without_vat + original_vat_amount
      end

      def caseworker_total_cost
        return 0 if total_cost_without_vat.to_i.zero?

        provider_requested_total_cost
      end

      def form_attributes
        attributes.slice('total_cost_without_vat').merge(
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
        table_fields[:vat] = format_vat_rate(vat_rate) if apply_vat == 'true'
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
          NumberTo.pounds(provider_requested_total_cost),
          apply_vat == 'true' ? format_vat_rate(vat_rate) : '0%',
          any_adjustments? ? NumberTo.pounds(caseworker_total_cost) : '',
        ]
      end
    end
  end
end
