module Nsm
  module V1
    class CoreCostSummary < BaseViewModel
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
          calculate_waiting(formatted:),
          calculate_travel(formatted:),
          calculate_disbursements(formatted:)
        ]
      end

      def summed_fields
        data = table_fields(formatted: false)

        {
          name: t('total', numeric: false),
          net_cost: format(data.sum { _1[:net_cost] }),
          vat: format(data.sum { _1[:vat] }),
          gross_cost: format(data.sum { _1[:gross_cost] }),
          allowed_net_cost: format(sum_allowed(data, :net_cost)),
          allowed_vat: format(sum_allowed(data, :vat)),
          allowed_gross_cost: format(sum_allowed(data, :gross_cost)),
        }
      end

      private

      def show_allowed?
        return @show_allowed unless @show_allowed.nil?

        @show_allowed ||=
          submission.part_grant? ||
          [disbursements, letters_calls, *work_items.values].any? { |rows| rows.any?(&:changed?) }
      end

      def sum_allowed(data, field)
        return nil if data.none? { _1[:"allowed_#{field}"] }

        data.sum { _1[:"allowed_#{field}"] || _1[field] }
      end

      def calculate_profit_costs(formatted:)
        calculate_row((work_items[PROFIT_COSTS] || []) + letters_calls, 'profit_costs', formatted:)
      end

      def calculate_waiting(formatted:)
        calculate_row(work_items['Waiting'] || [], 'waiting', formatted:)
      end

      def calculate_travel(formatted:)
        calculate_row(work_items['Travel'] || [], 'travel', formatted:)
      end

      def calculate_disbursements(formatted:)
        net_cost = disbursements.sum(&:original_total_cost_without_vat)
        vat = disbursements.sum(&:original_vat_amount)
        allowed_net_cost = show_allowed? ? disbursements.sum(&:total_cost_without_vat) : nil
        allowed_vat = show_allowed? ? disbursements.sum(&:vat_amount) : nil

        build_hash(
          name: 'disbursements',
          net_cost: net_cost,
          vat: vat,
          allowed_net_cost: allowed_net_cost,
          allowed_vat: allowed_vat,
          formatted: formatted
        )
      end

      def calculate_row(rows, name, formatted:)
        net_cost = rows.sum(&:provider_requested_amount)
        allowed_net_cost = show_allowed? ? rows.sum(&:caseworker_amount) : nil

        build_hash(
          name: name,
          net_cost: net_cost,
          vat: net_cost * vat_rate,
          allowed_net_cost: allowed_net_cost,
          allowed_vat: allowed_net_cost && (allowed_net_cost * vat_rate),
          formatted: formatted
        )
      end

      def build_hash(name:, net_cost:, vat:, allowed_net_cost:, allowed_vat:, formatted:)
        {
          name: t(name, numeric: false),
          net_cost: format(net_cost, formatted:),
          vat: format(vat, formatted:),
          gross_cost: format(net_cost + vat, formatted:),
          allowed_net_cost: format(allowed_vat && allowed_net_cost, formatted:),
          allowed_vat: format(allowed_vat, formatted:),
          allowed_gross_cost: format(allowed_vat && (allowed_net_cost + allowed_vat), formatted:),
        }
      end

      def work_items
        @work_items ||= BaseViewModel.build(:work_item, submission, 'work_items')
                                     .group_by { |work_item| group_type(work_item.work_type.to_s) }
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
          text: I18n.t("nsm.adjustments.show.#{key}"),
          numeric: numeric,
          width: width
        }
      end
    end
  end
end
