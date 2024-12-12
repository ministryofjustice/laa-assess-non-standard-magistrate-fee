module Nsm
  module V1
    class CoreCostSummary < BaseViewModel
      include ActionView::Helpers::UrlHelper
      include ActionView::Helpers::TagHelper
      include ActionView::Helpers::OutputSafetyHelper

      PROFIT_COSTS = 'profit_costs'.freeze

      attribute :submission

      def headers
        [
          t('items', numeric: false, width: 'govuk-!-width-one-quarter'),
          t('request_net'),
          t('request_vat'),
          t('request_gross'),
          t('allowed_net'),
          t('allowed_vat'),
          t('allowed_gross')
        ]
      end

      def table_fields
        [
          build_row(:profit_costs),
          build_row(:disbursements),
          build_row(:travel),
          build_row(:waiting)
        ]
      end

      def formatted_summed_fields
        totals = submission.totals[:totals]
        {
          name: t('total', numeric: false),
          net_cost: format(totals[:claimed_total_exc_vat]),
          vat: format(totals[:claimed_vat]),
          gross_cost: format(totals[:claimed_total_inc_vat]),
          allowed_net_cost: format_allowed(totals[:assessed_total_exc_vat]),
          allowed_vat: format_allowed(totals[:assessed_vat]),
          allowed_gross_cost: format_allowed(totals[:assessed_total_inc_vat]),
        }
      end

      def show_allowed?
        return @show_allowed unless @show_allowed.nil?

        @show_allowed ||=
          submission.part_grant? || any_changed?
      end

      def any_changed?
        [disbursements, letters_calls, work_items, additional_fees].any? { |rows| rows.any?(&:changed?) }
      end

      def any_reduced?
        [disbursements, letters_calls, work_items, additional_fees].any? { |rows| rows.any?(&:reduced?) }
      end

      def any_increased?
        [disbursements, letters_calls, work_items, additional_fees].any? { |rows| rows.any?(&:increased?) }
      end

      private

      def build_row(type)
        data = submission.totals[:cost_summary][type]

        {
          name: build_work_item_row_name(type,
                                         data[:at_least_one_claimed_work_item_assessed_as_type_with_different_summary_group]),
          net_cost: format(data[:claimed_total_exc_vat]),
          vat: format(data[:claimed_vat]),
          gross_cost: format(data[:claimed_total_inc_vat]),
          allowed_net_cost: format_allowed(data[:assessed_total_exc_vat]),
          allowed_vat: format_allowed(data[:assessed_vat]),
          allowed_gross_cost: format_allowed(data[:assessed_total_inc_vat]),
        }
      end

      def format(value)
        { text: NumberTo.pounds(value), numeric: true }
      end

      def format_allowed(value)
        return format(0) if submission.rejected?
        return '' unless show_allowed?

        format(value)
      end

      def t(key, numeric: true, width: nil)
        {
          text: I18n.t("nsm.review_and_adjusts.show.#{key}"),
          numeric: numeric,
          width: width
        }
      end

      def build_work_item_row_name(name_key, any_changed_type)
        return t(name_key, numeric: false) unless any_changed_type

        title_tag = tag.span(I18n.t("nsm.review_and_adjusts.show.#{name_key}"),
                             title: I18n.t('nsm.work_items.type_changes.explanation'))
        asterisk_tag = tag.sup { link_to(I18n.t('nsm.work_items.type_changes.asterisk'), '#fn*') }

        {
          text: safe_join([title_tag, ' ', asterisk_tag]),
          numeric: false,
        }
      end

      def work_items
        @work_items ||= BaseViewModel.build(:work_item, submission, 'work_items')
      end

      def letters_calls
        @letters_calls ||= LettersAndCallsSummary.new('submission' => submission).rows
      end

      def disbursements
        @disbursements ||= BaseViewModel.build(:disbursement, submission, 'disbursements')
      end

      def additional_fees
        @additional_fees ||= AdditionalFeesSummary.new('submission' => submission).rows
      end
    end
  end
end
