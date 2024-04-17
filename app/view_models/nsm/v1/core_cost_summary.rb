module Nsm
  module V1
    class CoreCostSummary < BaseViewModel
      PROFIT_COSTS = 'profit_costs'.freeze

      attribute :submission

      def headers
        [
          t('.items', numeric: false, width: 'govuk-!-width-one-quarter'),
          t('.request_net'),
          t('.request_vat'),
          t('.request_gross'),
          t('.allowed_net'),
          t('.allowed_vat'),
          t('.allowed_gross')
        ]
      end

      def table_fields(formatted = true)
        [
          profit_costs(formatted),
          waiting(formatted),
          travel(formatted),
          disbursements(formatted)
        ]
      end

      def summed_fields
        summed_fields = Hash.new { 0 }
        summed_fields[:name] = :total

        data = table_fields(false)

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

      def sum_allowed(data, field)
        return nil if data.none? { _1["allowed_#{field}".to_sym] }

        data.sum { _1["allowed_#{field}".to_sym] || _1[field] }
      end

      def profit_costs(formatted)
        letters_calls = LettersAndCallsSummary.new('submission' => submission).rows

        calculate_row(work_items[PROFIT_COSTS] || [] + letters_calls, 'profit_costs', formatted)
      end

      def waiting(formatted)
        calculate_row(work_items['waiting'] || [], 'waiting', formatted)
      end

      def travel(formatted)
        calculate_row(work_items['travel'] || [], 'travel', formatted)
      end

      def disbursements(formatted)
        rows = BaseViewModel.build(:disbursement, submission, 'disbursements')

        net_cost = rows.sum(&:original_total_cost_without_vat)
        vat = rows.sum(&:original_vat_amount)
        allowed_net_cost = rows.sum(&:total_cost_without_vat)
        allowed_vat = rows.sum(&:vat_amount)

        edited = net_cost != allowed_net_cost

        {
          name: t('disbursements', numeric: false),
          net_cost: format(net_cost, formatted),
          vat: format(vat, formatted),
          gross_cost: format(net_cost + vat, formatted),
          allowed_net_cost: format(edited ? allowed_net_cost : nil, formatted),
          allowed_vat: format(edited ? allowed_vat : nil, formatted),
          allowed_gross_cost: format(edited ? (allowed_net_cost + allowed_vat) : nil, formatted)
        }
      end

      def calculate_row(rows, name, formatted)
        net_cost = rows.sum(&:provider_requested_amount)
        allowed_net_cost =
          if rows.any? { |row| row.provider_requested_amount != row.caseworker_amount }
            rows.sum(&:caseworker_amount)
          else
            nil
          end

        {
          name: t(name, numeric: false),
          net_cost: format(net_cost, formatted),
          vat: format(net_cost * vat_rate, formatted),
          gross_cost: format(net_cost * (1.0 + vat_rate), formatted),
          allowed_net_cost: format(allowed_net_cost, formatted),
          allowed_vat: format(allowed_net_cost && allowed_net_cost * vat_rate, formatted),
          allowed_gross_cost: format(allowed_net_cost && allowed_net_cost * (1.0 + vat_rate), formatted),
        }
      end

      def work_items
        @work_items ||= BaseViewModel.build(:work_item, submission, 'work_items')
                     .group_by { |work_item| group_type(work_item.work_type.to_s) }
      end

      def group_type(work_type)
        return work_type if work_type.in?(%w[travel waiting])

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

      def format(value, formatted = true)
        return value unless formatted
        return '' if value.nil?

        { text: NumberTo.pounds(value), numeric: true }
      end

      def t(key, numeric: true, width: nil)
        {
          text: I18n.translate("nsm.adjustments.show.#{key}"),
          numeric: numeric,
          width: width
        }
      end
    end
  end
end
