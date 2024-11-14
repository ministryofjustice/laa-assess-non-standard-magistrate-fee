module Nsm
  module V1
    class Disbursement < BaseWithAdjustments
      LINKED_TYPE = 'disbursements'.freeze

      attribute :id
      # used to guess position when value not set in JSON blob when position is blank
      attribute :submission
      attribute :position, :integer
      attribute :disbursement_type, :translated, scope: 'nsm.disbursement_type'
      attribute :other_type, :translated, scope: 'nsm.other_disbursement_type'
      adjustable_attribute :miles, :decimal, precision: 10, scale: 3
      adjustable_attribute :total_cost_without_vat, :decimal, precision: 10, scale: 2
      attribute :disbursement_date, :date
      attribute :id, :string
      attribute :details, :string
      attribute :prior_authority, :string
      adjustable_attribute :apply_vat, :string
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
        calculation[:claimed_total_inc_vat]
      end
      alias provider_requested_amount provider_requested_total_cost

      def caseworker_total_cost
        calculation[:assessed_total_inc_vat]
      end
      alias caseworker_amount caseworker_total_cost

      def form_attributes
        attributes.slice('total_cost_without_vat', 'miles', 'apply_vat').merge(
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
        table_fields[:vat] = format_vat_rate
        table_fields[:total] = NumberTo.pounds(provider_requested_total_cost)

        table_fields
      end
      # rubocop:enable Metrics/AbcSize

      def pricing
        submission.rates.disbursements[disbursement_type.value.to_sym]
      end

      def format_vat_rate
        "#{(vat_rate * 100).to_i}%"
      end

      def vat_rate
        submission.rates.vat
      end

      def vat_amount
        calculation[:assessed_vat]
      end

      def original_vat_amount
        calculation[:claimed_vat]
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
        # Possible values of the raw `other_type` include:
        # - null (if disbursement_type is not "other")
        # - a known key, e.g. `"accountants"`
        # - a known key and its translation, e.g. `{ "en": "Accountants", "value": "accountants" }`
        # - a custom string, e.g. `"My favourite colour"`
        # - a custom string and its translation, e.g. `{ "en": "My favourite colour", "value": "My favourite colour" }`

        # `.value` gets us down to just dealing with null or a string, but we then need to test whether
        # this string is a known key we can translate. If not, it must be a custom, user-facing one.
        if other_type&.value.present?
          if I18n.t('laa_crime_forms_common.nsm.other_disbursement_type').key?(other_type.value.to_sym)
            other_type.translated
          else
            other_type.value
          end
        else
          disbursement_type.to_s
        end
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
        vat_changed? || cost_changed?
      end

      def vat_changed?
        apply_vat != original_apply_vat
      end

      def cost_changed?
        original_total_cost_without_vat != total_cost_without_vat
      end

      def backlink_path(claim)
        if any_adjustments?
          Rails.application.routes.url_helpers.adjusted_nsm_claim_disbursements_path(claim, anchor: id)
        else
          Rails.application.routes.url_helpers.nsm_claim_disbursements_path(claim, anchor: id)
        end
      end

      def calculation
        @calculation ||= LaaCrimeFormsCommon::Pricing::Nsm.calculate_disbursement(submission.data_for_calculation,
                                                                                  data_for_calculation)
      end

      def data_for_calculation
        {
          disbursement_type: disbursement_type.value,
          claimed_cost: original_total_cost_without_vat,
          claimed_miles: original_miles,
          claimed_apply_vat: original_apply_vat == 'true',
          assessed_cost: total_cost_without_vat,
          assessed_miles: miles,
          assessed_apply_vat: apply_vat == 'true',
        }
      end
    end
  end
end
