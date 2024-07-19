module Nsm
  module V1
    class LetterAndCall < BaseWithAdjustments
      LINKED_TYPE = 'letters_and_calls'.freeze
      ID_FIELDS = %w[type value].freeze

      attribute :type, :translated
      adjustable_attribute :count, :integer
      adjustable_attribute :uplift, :integer
      attribute :pricing, :decimal
      attribute :vat_rate
      attribute :firm_office

      class << self
        def headers
          [
            t('.items', width: 'govuk-!-width-one-fifth', numeric: false),
            t('.number'),
            t('.uplift_requested'),
            t('.provider_requested'),
            t('.caseworker_allowed')
          ]
        end

        private

        def t(key, width: nil, numeric: true)
          {
            text: I18n.t("nsm.letters_and_calls.index.#{key}"),
            numeric: numeric,
            width: width
          }
        end
      end

      def vat_registered?
        firm_office['vat_registered'] == 'yes'
      end

      def provider_requested_amount
        calculate_cost(original: true)
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

      def type_name
        type.to_s.downcase
      end

      def id
        type.value
      end

      def form_attributes
        attributes.except(
          'pricing', 'adjustment_comment', 'vat_rate', 'firm_office', 'count_original', 'uplift_original'
        ).merge(
          'type' => type.value,
          'explanation' => adjustment_comment,
        )
      end

      def table_fields
        [
          type.to_s,
          format(original_count.to_s, as: :number),
          format(original_uplift.to_i, as: :percentage),
          format(provider_requested_amount),
          format(any_adjustments? && caseworker_amount)
        ]
      end

      def provider_fields
        rows = {
          '.number' => original_count.to_s,
          '.rate' => NumberTo.pounds(pricing),
          '.uplift_requested' => "#{original_uplift.to_i}%",
        }

        if vat_registered?
          rows['.vat'] = NumberTo.percentage(vat_rate)
          rows['.total_claimed_inc_vate'] = NumberTo.pounds(provider_requested_amount_inc_vat)
        else
          rows['.total_claimed'] = NumberTo.pounds(provider_requested_amount)
        end

        rows
      end

      def uplift?
        !original_uplift.to_i.zero?
      end

      def changed?
        provider_requested_amount != caseworker_amount
      end

      private

      def calculate_cost(original: false)
        scoped_count, scoped_uplift = original ? [original_count, original_uplift] : [count, uplift]
        pricing * scoped_count * (100 + scoped_uplift.to_i) / 100
      end

      def format(value, as: :pounds)
        return '' if value.nil? || value == false

        case as
        when :percentage then { text: NumberTo.percentage(value, multiplier: 1), numeric: true }
        when :number then { text: value, numeric: true }
        else { text: NumberTo.pounds(value), numeric: true }
        end
      end
    end
  end
end
