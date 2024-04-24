module Nsm
  module V1
    class WorkItem < BaseWithAdjustments
      LINKED_TYPE = 'work_items'.freeze

      attribute :id, :string
      attribute :work_type, :translated
      adjustable_attribute :time_spent, :time_period
      attribute :completed_on, :date

      attribute :pricing, :float
      adjustable_attribute :uplift, :integer
      attribute :fee_earner, :string
      attribute :vat_rate, :float
      attribute :firm_office

      class << self
        def headers
          [
            t('item', width: 'govuk-!-width-one-fifth', numeric: false),
            t('claimed_time'),
            t('claimed_uplift'),
            t('claimed_net_cost'),
            t('allowed_time'),
            t('allowed_uplift'),
            t('allowed_net_cost'),
            t('action')
          ]
        end

        def t(key, width: nil, numeric: true)
          {
            text: I18n.t("nsm.work_items.index.#{key}"),
            numeric: numeric,
            width: width
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

      def table_fields
        [
          work_type.to_s,
          format(original_time_spent, as: :time),
          format(original_uplift.to_i, as: :percentage),
          format(provider_requested_amount),
          format(any_adjustments? && time_spent, as: :time),
          format(any_adjustments? && uplift.to_i, as: :percentage),
          format(any_adjustments? && caseworker_amount)
        ]
      end

      def attendance?
        %w[attendance_with_counsel attendance_without_counsel].include?(work_type.value)
      end

      def provider_fields
        rows = {
          '.date' => format_in_zone(completed_on),
          '.time_spent' => format_period(original_time_spent),
          '.fee_earner' => fee_earner.to_s,
          '.uplift_claimed' => "#{original_uplift}%",
        }
        if vat_registered?
          rows['.vat'] = NumberTo.percentage(vat_rate)
          rows['.total_claimed_inc_vate'] = NumberTo.pounds_inc_vat(provider_requested_amount_inc_vat)
        else
          rows['.total_claimed'] = NumberTo.pounds(provider_requested_amount)
        end

        rows
      end

      private

      def calculate_cost(original: false)
        scoped_uplift, scoped_time_spent = original ? [original_uplift, original_time_spent] : [uplift, time_spent]
        pricing * scoped_time_spent * (100 + scoped_uplift.to_i) / 100 / 60
      end

      def format(value, as: :pounds)
        return '' if value.nil? || value == false

        case as
        when :percentage then { text: NumberTo.percentage(value, multiplier: 1), numeric: true }
        when :time then { text: ApplicationController.helpers.format_period(value, style: :long_html), numeric: true }
        else { text: NumberTo.pounds(value), numeric: true }
        end
      end
    end
  end
end
