module Nsm
  module V1
    class YouthCourtFee < BaseWithAdjustments
      LINKED_TYPE = 'youth_court_fee'.freeze

      adjustable_attribute :include_youth_court_fee, :boolean
      attribute :youth_court_fee_adjustment_comment, :string
      attribute :submission

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
            value: calculated_youth_court_fee
          }
        ].compact
      end

      def rows
        { title:, data: }
      end

      def any_adjustments?
        youth_court_fee_adjustment_comment.present?
      end

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

      private

      def calculated_youth_court_fee
        NumberTo.pounds(submission.totals.dig(:additional_fees, :youth_court_fee, :claimed_total_exc_vat))
      end
    end
  end
end
