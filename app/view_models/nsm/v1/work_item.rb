module Nsm
  module V1
    class WorkItem < BaseWithAdjustments
      LINKED_TYPE = 'work_items'.freeze

      attribute :id, :string
      # used to guess position when value not set in JSON blob when position is blank
      attribute :submission
      attribute :position, :integer
      adjustable_attribute :work_type, :translated
      adjustable_attribute :time_spent, :time_period
      attribute :completed_on, :date

      adjustable_attribute :pricing, :decimal
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
          '.item_rate' => NumberTo.pounds(original_pricing),
          '.uplift_claimed' => "#{original_uplift.to_i}%",
          '.total_claimed' => NumberTo.pounds(provider_requested_amount),
        }
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

      private

      def calculate_cost(original: false)
        scoped_uplift, scoped_time_spent, scoped_pricing = if original
                                                             [original_uplift, original_time_spent, original_pricing]
                                                           else
                                                             [uplift, time_spent, pricing]
                                                           end
        # We need to use a Rational because some numbers divided by 60 cannot be accurately represented as a decimal,
        # and when summing up multiple work items with sub-penny precision, those small inaccuracies can lead to
        # a larger inaccuracy when the total is eventually rounded to 2 decimal places.
        Rational(scoped_pricing * scoped_time_spent * (100 + scoped_uplift.to_i), 100 * 60)
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
