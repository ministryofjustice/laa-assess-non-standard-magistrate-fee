module Nsm
  module V1
    class WorkItem < BaseWithAdjustments
      LINKED_TYPE = 'work_items'.freeze

      attribute :id, :string
      # used to guess position when value not set in JSON blob when position is blank
      attribute :submission
      attribute :position, :integer
      attribute :work_type, :translated
      adjustable_attribute :time_spent, :time_period
      attribute :completed_on, :date

      attribute :pricing, :decimal
      adjustable_attribute :uplift, :integer
      attribute :fee_earner, :string
      attribute :vat_rate, :decimal
      attribute :firm_office

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
      end

      def vat_registered?
        firm_office['vat_registered'] == 'yes'
      end

      def provider_requested_amount
        @provider_requested_amount ||= calculate_cost(original: true)
      end

      def provider_requested_amount_inc_vat
        return provider_requested_amount unless vat_registered?

        provider_requested_amount * (1 + vat_rate)
      end

      def caseworker_amount
        @caseworker_amount ||= calculate_cost
      end

      def caseworker_amount_inc_vat
        return caseworker_amount unless vat_registered?

        caseworker_amount * (1 + vat_rate)
      end

      def uplift?
        !original_uplift.to_i.zero?
      end

      def form_attributes
        attributes.slice('time_spent', 'uplift').merge(
          'explanation' => adjustment_comment
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

      def formatted_allowed_amount
        format(any_adjustments? && caseworker_amount)
      end

      def attendance?
        %w[attendance_with_counsel attendance_without_counsel].include?(work_type.value)
      end

      def provider_fields
        rows = {
          '.date' => format_in_zone(completed_on),
          '.time_spent' => format_period(original_time_spent),
          '.fee_earner' => fee_earner.to_s,
          '.uplift_claimed' => "#{original_uplift.to_i}%",
        }
        if vat_registered?
          rows['.vat'] = NumberTo.percentage(vat_rate)
          rows['.total_claimed_inc_vate'] = NumberTo.pounds(provider_requested_amount_inc_vat)
        else
          rows['.total_claimed'] = NumberTo.pounds(provider_requested_amount)
        end

        rows
      end

      def changed?
        provider_requested_amount != caseworker_amount
      end

      private

      def calculate_cost(original: false)
        scoped_uplift, scoped_time_spent = original ? [original_uplift, original_time_spent] : [uplift, time_spent]
        # We need to use a Rational because some numbers divided by 60 cannot be accurately represented as a decimal,
        # and when summing up multiple work items with sub-penny precision, those small inaccuracies can lead to
        # a larger inaccuracy when the total is eventually rounded to 2 decimal places.
        Rational(pricing * scoped_time_spent * (100 + scoped_uplift.to_i), 100 * 60)
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
