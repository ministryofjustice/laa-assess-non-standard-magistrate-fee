module Nsm
  module V1
    class AdditionalFee < BaseWithAdjustments
      attribute :type
      attribute :submission
      attribute :claimed_total_exc_vat
      attribute :claimed_vatable
      attribute :assessed_total_exc_vat
      attribute :assessed_vatable
      attribute :claimed_vat
      attribute :assessed_vat
      attribute :claimed_total_inc_vat
      attribute :assessed_total_inc_vat

      class << self
        def headers
          [
            t('.fee_type', width: 'govuk-!-width-one-fifth', numeric: false),
            t('.net_cost_claimed'),
            t('.net_cost_allowed')
          ]
        end

        def adjusted_headers
          [
            t('.fee_type', width: 'govuk-!-width-one-fifth', numeric: false),
            t('.reason_for_adjustments', numeric: false),
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

      def backlink_path(claim)
        if any_adjustments?
          Rails.application.routes.url_helpers.adjusted_nsm_claim_additional_fees_path(claim)
        else
          Rails.application.routes.url_helpers.nsm_claim_additional_fees_path(claim)
        end
      end

      def table_fields
        [
          I18n.t("nsm.additional_fees.index.#{type}"),
          format(claimed_total_exc_vat),
          format(any_adjustments? ? assessed_total_exc_vat : nil),
        ]
      end

      def provider_fields
        {
          '.additional_fee' => I18n.t("nsm.additional_fees.edit.#{type}"),
          '.net_cost_claimed' => NumberTo.pounds(claimed_total_exc_vat)
        }
      end

      private

      def format(value)
        return '' if value.nil? || value == false

        { text: NumberTo.pounds(value), numeric: true }
      end
    end
  end
end
