module Nsm
  module V1
    class WorkItemSummary < BaseViewModel
      attribute :submission

      def header
        [
          t('items', numeric: false),
          t('requested_time'),
          t('requested_cost'),
          t('allowed_time'),
          t('allowed_cost')
        ]
      end

      def table_fields
        work_item_data.map do |data|
          format_row(data)
        end
      end

      def footer
        format_row([t('total', numeric: false)] + summed_values(work_items, periods: false))
      end

      def format_row(data)
        work_type, requested_cost, requested_time, allowed_cost, allowed_time = *data
        result = [
          work_type,
          { text: format_period(requested_time, style: :line_html), numeric: true },
          { text: NumberTo.pounds(requested_cost), numeric: true },
        ]
        if requested_cost != allowed_cost || submission.part_grant?
          result << { text: format_period(allowed_time, style: :line_html), numeric: true }
          result << { text: NumberTo.pounds(allowed_cost), numeric: true }
        else
          result << '' << ''
        end

        result
      end

      def work_item_data
        @work_item_data ||=
          work_items
          .group_by { |work_item| work_item.work_type.to_s }
          .map do |translated_work_type, work_items_for_type|
            [
              translated_work_type,
              *summed_values(work_items_for_type)
            ]
          end
      end

      private

      def work_items
        @work_items ||= BaseViewModel.build(:work_item, submission, 'work_items')

      end

      def summed_values(work_items, periods: true)
        [
          work_items.sum(&:provider_requested_amount),
          periods ? work_items.sum(&:original_time_spent) : '',
          work_items.sum(&:caseworker_amount),
          periods ? work_items.sum(&:time_spent) : '',
        ]
      end

      def t(key, numeric: true)
        {
          text: I18n.t("nsm.work_items.index.#{key}"),
          numeric: numeric
        }
      end
    end
  end
end
