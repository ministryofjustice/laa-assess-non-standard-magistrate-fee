module Nsm
  module V1
    class WorkItemSummary < BaseViewModel
      include ActionView::Helpers::TagHelper
      include ActionView::Helpers::UrlHelper

      WORK_TYPES = %w[
        travel
        waiting
        attendance_with_counsel
        attendance_without_counsel
        preparation
        advocacy
      ].freeze

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
        WORK_TYPES.map do |work_type|
          data = data_for(work_type)
          format_row(data)
        end
      end

      def footer
        format_row(
          [t('total', numeric: false)] + summed_values(work_items, work_items, periods: false),
          accessibility_text: true
        )
      end

      def format_row(data, accessibility_text: false)
        work_type, requested_cost, requested_time, allowed_cost, allowed_time, any_changed_types = *data
        result = [
          (work_type.is_a?(String) && any_changed_types ? row_with_changed_type(work_type) : work_type),
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

      def data_for(work_type)
        claimed_work_items = work_items.select { _1.original_work_type.value == work_type }
        allowed_work_items = work_items.select { _1.work_type.value == work_type }
        [
          I18n.t("nsm.work_items.work_types.#{work_type}"),
          *summed_values(claimed_work_items, allowed_work_items)
        ]
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
      end

      def summed_values(claimed_work_items, allowed_work_items, periods: true)
        [
          claimed_work_items.sum(&:provider_requested_amount),
          periods ? claimed_work_items.sum(&:original_time_spent) : '',
          allowed_work_items.sum(&:caseworker_amount),
          periods ? allowed_work_items.sum(&:time_spent) : '',
          claimed_work_items.any? { _1.work_type != _1.original_work_type }
        ]
      end

      def t(key, numeric: true)
        {
          text: I18n.t("nsm.work_items.index.#{key}"),
          numeric: numeric
        }
      end

      def row_with_changed_type(name)
        title_tag = tag.span(name,
                             title: I18n.t('nsm.work_items.type_changes.explanation'))
        asterisk_tag = tag.sup do
          link_to(I18n.t('nsm.work_items.type_changes.asterisk'), '#fn*')
        end

        safe_join([title_tag, asterisk_tag])
      end
    end
  end
end
