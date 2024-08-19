module Nsm
  module V1
    class WorkItemSummary < BaseViewModel
      include ActionView::Helpers::TagHelper

      WORK_TYPE_ORDER = {
        'travel' => 0,
        'waiting' => 1,
        'attendance_with_counsel' => 2,
        'attendance_without_counsel' => 3,
        'preparation' => 4,
        'advocacy' => 5
      }.freeze

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
        format_row(
          [t('total', numeric: false)] + summed_values(work_items, periods: false),
          accessibility_text: true
        )
      end

      def format_row(data, accessibility_text: false)
        work_type, requested_cost, requested_time, allowed_cost, allowed_time, any_changed_types = *data
        result = [
          (work_type.is_a?(String) && any_changed_types ? "#{work_type} *" : work_type),
          { text: format_period(requested_time, style: :minimal_html), numeric: true },
          { text: prefix('claimed', accessibility_text:) + NumberTo.pounds(requested_cost), numeric: true },
        ]
        if show_allowed?
          result << { text: format_period(allowed_time, style: :minimal_html), numeric: true }
          result << { text: prefix('allowed', accessibility_text:) + NumberTo.pounds(allowed_cost), numeric: true }
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

      def any_type_changes?
        work_items.any? { _1.work_type_original.present? }
      end

      private

      def prefix(key, accessibility_text:)
        return '' unless accessibility_text

        tag.span(I18n.t("nsm.work_items.index.accessible.#{key}"), class: 'govuk-visually-hidden')
      end

      def show_allowed?
        submission.part_grant? || work_items.any?(&:changed?)
      end

      def work_items
        @work_items ||= BaseViewModel.build(:work_item, submission, 'work_items')
                                     .sort_by { WORK_TYPE_ORDER[_1.work_type.value] }
      end

      def summed_values(work_items, periods: true)
        [
          work_items.sum(&:provider_requested_amount),
          periods ? work_items.sum(&:original_time_spent) : '',
          work_items.sum(&:caseworker_amount),
          periods ? work_items.sum(&:time_spent) : '',
          work_items.any? { _1.work_type_original.present? }
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
