module Nsm
  module V1
    class AdditionalFee < BaseWithAdjustments
      LINKED_TYPE = 'additional_fees'.freeze

      attribute :type
      attribute :submission
      attribute :include_youth_court_fee
      attribute :claimed_total_exc_vat
      attribute :claimed_vatable
      attribute :assessed_total_exc_vat
      attribute :assessed_vatable
      attribute :claimed_vat
      attribute :assessed_vat
      attribute :claimed_total_inc_vat
      attribute :assessed_total_inc_vat

      adjustable_attribute :include_youth_court_fee, :boolean
      attribute :youth_court_fee_adjustment_comment, :string

      class << self
        def headers
          [
            t('.fee_type', width: 'govuk-!-width-one-fifth', numeric: false),
            t('.net_cost_claimed'),
            t('.net_cost_allowed')
          ]
        end

        private

        def t(key, width: nil, numeric: true, scope: 'nsm.additional_fees.index')
          {
            text: I18n.t(key, scope:),
            numeric: numeric,
            width: width
          }
        end
      end

      def key
        'summary_table'
      end

      def title
        I18n.t(".nsm.youth_court_fee_adjustments.#{key}.title")
      end

      def data
        [
          {
            title: I18n.t(".nsm.youth_court_fee_adjustments.#{key}.additional_fee"),
            value: I18n.t(".nsm.youth_court_fee_adjustments.#{key}.youth_court_fee")
          },
          {
            title: I18n.t(".nsm.youth_court_fee_adjustments.#{key}.net_cost_claimed"),
            value: NumberTo.pounds(calculated_claimed_total_exc_vat)
          }
        ].compact
      end

      def rows
        { title:, data: }
      end

      def any_adjustments?
        submission.data['youth_court_fee_adjustment_comment'].present?
      end
      alias changed? any_adjustments?

      def form_attributes
        remove_bool = ActiveModel::Type::Boolean.new.cast(include_youth_court_fee)
        remove_youth_court_fee = include_youth_court_fee_original.nil? ? nil : !remove_bool

        {
          'remove_youth_court_fee' => remove_youth_court_fee,
          'explanation' => youth_court_fee_adjustment_comment
        }
      end

      def backlink_path(claim)
        # :nocov:
        # TODO: CRM457-2306: Remove these as the fields will exist
        if any_adjustments?
          Rails.application.routes.url_helpers.adjusted_nsm_claim_additional_fees_path(claim)
        # :nocov:
        else
          Rails.application.routes.url_helpers.nsm_claim_additional_fees_path(claim)
        end
      end

      def table_fields
        [
          I18n.t("nsm.additional_fees.index.#{type}"),
          format(claimed_total_exc_vat),
          format(any_adjustments? ? assessed_total_inc_vat : nil),
        ]
      end

      def provider_fields
        {
          '.additional_fee' => I18n.t("nsm.additional_fees.edit.#{type}"),
          '.net_cost_claimed' => NumberTo.pounds(claimed_total_exc_vat)
        }
      end

      def calculated_claimed_total_exc_vat
        calculated[:claimed_total_exc_vat]
      end

      def calculated
        @calculated ||= submission.additional_fees[:youth_court_fee]
      end

      private

      def format(value)
        return '' if value.nil? || value == false

        { text: NumberTo.pounds(value), numeric: true }
      end
    end
  end
end
