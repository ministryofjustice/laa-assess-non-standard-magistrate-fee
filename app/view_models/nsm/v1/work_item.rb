module Nsm
  module V1
    class WorkItem < BaseWithAdjustments
      LINKED_TYPE = 'work_items'.freeze
      ID_FIELDS = %w[id].freeze

      attribute :id, :string
      attribute :work_type, :translated
      adjustable_attribute :time_spent, :time_period
      attribute :completed_on, :date

      attribute :pricing, :float
      adjustable_attribute :uplift, :integer
      attribute :fee_earner, :string
      attribute :vat_rate, :float
      attribute :firm_office

      def vat_registered?
        firm_office['vat_registered'] == 'yes'
      end

      def provider_requested_amount
        @provider_requested_amount ||= CostCalculator.cost(:work_item, self, :provider_requested)
      end

      def provider_requested_amount_inc_vat
        return provider_requested_amount unless vat_registered?

        provider_requested_amount * (1 + vat_rate)
      end

      def provider_requested_time_spent
        @provider_requested_time_spent ||= original_time_spent.to_i
      end

      def provider_requested_uplift
        @provider_requested_uplift ||= original_uplift.to_i
      end

      def caseworker_amount
        @caseworker_amount ||= CostCalculator.cost(:work_item, self, :caseworker)
      end

      def caseworker_amount_inc_vat
        return caseworker_amount unless vat_registered?

        caseworker_amount * (1 + vat_rate)
      end

      def caseworker_time_spent
        time_spent.to_i
      end

      def caseworker_uplift
        uplift.to_i
      end

      def uplift?
        !provider_requested_uplift.to_i.zero?
      end

      def form_attributes
        attributes.slice('time_spent', 'uplift').merge(
          'explanation' => previous_explanation
        )
      end

      def table_fields
        [
          work_type.to_s,
          "#{provider_requested_uplift.to_i}%",
          ApplicationController.helpers.format_period(provider_requested_time_spent, style: :long),
          any_adjustments? ? "#{caseworker_uplift}%" : '',
          any_adjustments? ? ApplicationController.helpers.format_period(caseworker_time_spent, style: :long) : ''
        ]
      end

      def attendance?
        %w[attendance_with_counsel attendance_without_counsel].include?(work_type.value)
      end

      # rubocop:disable Metrics/MethodLength
      def provider_fields
        rows = {
          '.date' => format_in_zone(completed_on),
          '.time_spent' => format_period(provider_requested_time_spent),
          '.fee_earner' => fee_earner.to_s,
          '.uplift_claimed' => "#{provider_requested_uplift}%",
        }
        if vat_registered?
          rows['.vat'] = NumberTo.percentage(vat_rate)
          rows['.total_claimed_inc_vate'] = NumberTo.pounds_inc_vat(provider_requested_amount_inc_vat)
        else
          rows['.total_claimed'] = NumberTo.pounds(provider_requested_amount)
        end

        rows
      end
      # rubocop:enable Metrics/MethodLength
    end
  end
end
