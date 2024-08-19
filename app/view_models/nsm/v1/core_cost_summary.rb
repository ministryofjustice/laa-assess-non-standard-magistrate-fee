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

      def table_fields(formatted: true)
        [
          calculate_profit_costs(formatted:),
          calculate_disbursements(formatted:),
          calculate_travel(formatted:),
          calculate_waiting(formatted:)
        ]
      end

      def summed_fields
        @summed_fields ||= begin
          data = table_fields(formatted: false)

          {
            net_cost: data.sum { _1[:net_cost] },
            vat: data.sum { _1[:vat] },
            gross_cost: data.sum { _1[:gross_cost] },
            allowed_net_cost: sum_allowed(data, :net_cost),
            allowed_vat: sum_allowed(data, :vat),
            allowed_gross_cost: sum_allowed(data, :gross_cost),
          }
        end
      end

      def formatted_summed_fields
        { name: t('total', numeric: false) }.merge(summed_fields.transform_values { format(_1) })
      end

      def show_allowed?
        return @show_allowed unless @show_allowed.nil?

        @show_allowed ||=
          submission.part_grant? ||
          [disbursements, letters_calls, work_items].any? { |rows| rows.any?(&:changed?) }
      end

      private

      def sum_allowed(data, field)
        return 0 if submission.rejected?

        return nil if data.none? { _1[:"allowed_#{field}"] }

        data.sum { _1[:"allowed_#{field}"] || _1[field] }
      end

      def calculate_profit_costs(formatted:)
        calculate_work_items_row(PROFIT_COSTS, 'profit_costs', extra_rows: letters_calls, formatted: formatted)
      end

      def calculate_waiting(formatted:)
        calculate_work_items_row('Waiting', 'waiting', formatted:)
      end

      def calculate_travel(formatted:)
        calculate_work_items_row('Travel', 'travel', formatted:)
      end

      def calculate_disbursements(formatted:)
        net_cost = disbursements.sum(&:original_total_cost_without_vat)
        vat = disbursements.sum(&:original_vat_amount)
        allowed_net_cost = show_allowed? ? disbursements.sum(&:total_cost_without_vat) : nil
        allowed_vat = show_allowed? ? disbursements.sum(&:vat_amount) : nil

        build_hash(
          name: t('disbursements', numeric: false),
          net_cost: net_cost,
          vat: vat,
          allowed_net_cost: allowed_net_cost,
          allowed_vat: allowed_vat,
          formatted: formatted
        )
      end

      def calculate_work_items_row(type, name, formatted:, extra_rows: [])
        claimed_rows = work_items_of_type(type, type_type: :claimed)
        net_cost = claimed_rows.sum(&:provider_requested_amount) + extra_rows.sum(&:provider_requested_amount)
        if show_allowed?
          allowed_rows = work_items_of_type(type, type_type: :allowed)
          allowed_net_cost = allowed_rows.sum(&:caseworker_amount) + extra_rows.sum(&:caseworker_amount)
        end

        calculate_hash(name, claimed_rows, allowed_rows, net_cost, allowed_net_cost, formatted)
      end

      def calculate_hash(name, claimed_rows, allowed_rows, net_cost, allowed_net_cost, formatted)
        any_changed_type = show_allowed? && claimed_rows.any? { !_1.in?(allowed_rows) }

        build_hash(
          name: build_work_item_row_name(name, any_changed_type),
          net_cost: net_cost,
          vat: net_cost * vat_rate,
          allowed_net_cost: allowed_net_cost,
          allowed_vat: allowed_net_cost && (allowed_net_cost * vat_rate),
          formatted: formatted
        )
      end

      def build_hash(name:, net_cost:, vat:, allowed_net_cost:, allowed_vat:, formatted:)
        {
          name: name,
          net_cost: format(net_cost, formatted:),
          vat: format(vat, formatted:),
          gross_cost: format(net_cost + vat, formatted:),
          allowed_net_cost: format(allowed_vat && allowed_net_cost, formatted:),
          allowed_vat: format(allowed_vat, formatted:),
          allowed_gross_cost: format(allowed_vat && (allowed_net_cost + allowed_vat), formatted:),
        }
      end

      def work_items_of_type(type, type_type:)
        field = type_type == :claimed ? :original_work_type : :work_type
        work_items.select { group_type(_1.send(field).to_s) == type }
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

      def group_type(work_type)
        return work_type if work_type.in?(%w[Travel Waiting])

        PROFIT_COSTS
      end

      def vat_rate
        @vat_rate ||=
          if submission.data.dig('firm_office', 'vat_registered') == 'yes'
            submission.data['vat_rate'] || 0.2
          else
            0.0
          end
      end

      def format(value, formatted: true)
        return value unless formatted
        return '' if value.nil?

        { text: NumberTo.pounds(value), numeric: true }
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
          text: safe_join([title_tag, asterisk_tag]),
          numeric: false,
        }
      end
    end
  end
end
