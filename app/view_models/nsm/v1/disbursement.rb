module Nsm
  module V1
    class Disbursement < BaseWithAdjustments
      LINKED_TYPE = 'disbursements'.freeze

      attribute :id
      # used to guess position when value not set in JSON blob when position is blank
      attribute :submission
      attribute :position, :integer
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
      attribute :adjustment_comment

      class << self
        def headers
          {
            'item' => [],
            'cost' => [],
            'date' => [],
            'claimed_net' => ['govuk-table__header--numeric'],
            'claimed_vat' => ['govuk-table__header--numeric'],
            'claimed_gross' => ['govuk-table__header--numeric'],
            'allowed_gross' => ['govuk-table__header--numeric']
          }
        end

        def adjusted_headers
          {
            'item' => [],
            'cost' => [],
            'reason' => [],
            'allowed_net' => ['govuk-table__header--numeric'],
            'allowed_vat' => ['govuk-table__header--numeric'],
            'allowed_gross' => ['govuk-table__header--numeric']
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
        table_fields[:date] = disbursement_date.to_fs(:stamp)
        table_fields[:type] = type_name.capitalize
        table_fields[:miles] = miles.to_s if miles.present?
        table_fields[:details] = details.capitalize
        table_fields[:prior_authority] = prior_authority.capitalize if prior_authority
        table_fields[:vat] = format_vat_rate(vat_rate)
        table_fields[:total] = NumberTo.pounds(provider_requested_total_cost)

        table_fields
      end
      # rubocop:enable Metrics/AbcSize

      def format_vat_rate(rate)
        "#{(rate * 100).to_i}%"
      end

      def position
        super || begin
          pos = submission.data['disbursements']
                          .sort_by { [_1['disbursement_date'], _1['id']] }
                          .index { _1['id'] == id }
          pos + 1
        end
      end

      def type_name
        other_type.to_s.presence || disbursement_type.to_s
      end

      def date
        disbursement_date.strftime('%-d %b %Y')
      end

      def reason
        adjustment_comment
      end

      def claimed_net
        format(original_total_cost_without_vat)
      end

      def claimed_vat
        format(original_vat_amount)
      end

      def claimed_gross
        format(provider_requested_total_cost)
      end

      def allowed_net
        format(total_cost_without_vat)
      end

      def allowed_vat
        format(vat_amount)
      end

      def allowed_gross
        format(any_adjustments? && caseworker_total_cost)
      end

      def format(value)
        return '' if value.nil? || value == false

        NumberTo.pounds(value)
      end

      def changed?
        original_total_cost_without_vat != total_cost_without_vat
      end

      def reduced?
        provider_requested_total_cost > caseworker_total_cost
      end

      def increased?
        provider_requested_total_cost < caseworker_total_cost
      end

      def backlink_path(claim)
        if any_adjustments?
          Rails.application.routes.url_helpers.adjusted_nsm_claim_disbursements_path(claim, anchor: id)
        else
          Rails.application.routes.url_helpers.nsm_claim_disbursements_path(claim, anchor: id)
        end
      end
    end
  end
end
