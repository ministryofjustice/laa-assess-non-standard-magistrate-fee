module Nsm
  module V1
    class WorkItem < BaseWithAdjustments
      LINKED_TYPE = 'work_items'.freeze

      attribute :id, :string
      # used to guess position when value not set in JSON blob when position is blank
      attribute :submission
      attribute :position, :integer
      adjustable_attribute :work_type, :translated, scope: 'nsm.work_type'
      adjustable_attribute :time_spent, :time_period
      attribute :completed_on, :date

      adjustable_attribute :uplift, :integer
      attribute :fee_earner, :string
      attribute :adjustment_comment

      class << self
        def headers
          {
            'item' => [],
            'cost' => [],
            'date' => [],
            'fee_earner' => [],
            'claimed_time' => ['govuk-table__header--numeric'],
            'claimed_uplift' => ['govuk-table__header--numeric'],
            'claimed_net_cost' => ['govuk-table__header--numeric'],
            'allowed_net_cost' => ['govuk-table__header--numeric'],
          }
        end

        def adjusted_headers
          {
            'item' => [],
            'cost' => [],
            'reason' => [],
            'allowed_time' => ['govuk-table__header--numeric'],
            'allowed_uplift' => ['govuk-table__header--numeric'],
            'allowed_net_cost' => ['govuk-table__header--numeric'],
          }
        end
      end

      def provider_requested_amount
        @provider_requested_amount ||= calculate_cost(original: true)
      end

      def caseworker_amount
        @caseworker_amount ||= calculate_cost
      end

      def uplift?
        !original_uplift.to_i.zero?
      end

      def form_attributes
        attributes.slice('time_spent', 'uplift').merge(
          'explanation' => adjustment_comment,
          'work_type_value' => work_type.value,
        )
      end

      def position
        super || begin
          pos = submission.data['work_items']
                          .sort_by { [_1['completed_on'], _1['id']] }
                          .index { _1['id'] == id }
          pos + 1
        end
      end

      def reason
        adjustment_comment
      end

      def formatted_completed_on
        format(completed_on, as: :date)
      end

      def formatted_time_spent
        format(original_time_spent, as: :time)
      end

      def formatted_uplift
        format(original_uplift.to_i, as: :percentage)
      end

      def formatted_requested_amount
        format(provider_requested_amount)
      end

      def formatted_allowed_time_spent
        format(time_spent, as: :time)
      end

      def formatted_allowed_uplift
        format(uplift.to_i, as: :percentage)
      end

      def formatted_allowed_amount
        format(any_adjustments? && caseworker_amount)
      end

      def provider_fields
        {
          '.work_type' => original_work_type.translated,
          '.date' => format_in_zone(completed_on),
          '.fee_earner' => fee_earner.to_s,
          '.time_spent' => format_period(original_time_spent),
          '.item_rate' => NumberTo.pounds(submission.rates.work_items[original_work_type.value.to_sym]),
          '.uplift_claimed' => "#{original_uplift.to_i}%",
          '.total_claimed' => NumberTo.pounds(provider_requested_amount),
        }
      end

      def pricing
        submission.rates.work_items[work_type.value.to_sym]
      end

      def changed?
        adjustment_comment.present?
      end

      def backlink_path(claim)
        if any_adjustments?
          Rails.application.routes.url_helpers.adjusted_nsm_claim_work_items_path(claim, anchor: id)
        else
          Rails.application.routes.url_helpers.nsm_claim_work_items_path(claim, anchor: id)
        end
      end

      def data_for_calculation
        {
          claimed_time_spent_in_minutes: original_time_spent.to_i,
          claimed_work_type: original_work_type.value,
          claimed_uplift_percentage: original_uplift,
          assessed_time_spent_in_minutes: time_spent.to_i,
          assessed_work_type: work_type.value,
          assessed_uplift_percentage: uplift,
        }
      end

      private

      def calculate_cost(original: false)
        data = LaaCrimeFormsCommon::Pricing::Nsm.calculate_work_item(submission.data_for_calculation,
                                                                     data_for_calculation)

        original ? data[:claimed_total_exc_vat] : data[:assessed_total_exc_vat]
      end

      def format(value, as: :pounds)
        return '' if value.nil? || value == false

        case as
        when :percentage then NumberTo.percentage(value, multiplier: 1)
        when :time then format_period(value, style: :minimal_html)
        when :date then format_in_zone(value, format: '%-d %b %Y')
        else NumberTo.pounds(value)
        end
      end
    end
  end
end
