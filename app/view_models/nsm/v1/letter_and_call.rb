module Nsm
  module V1
    class LetterAndCall < BaseWithAdjustments
      LINKED_TYPE = 'letters_and_calls'.freeze
      ID_FIELDS = %w[type value].freeze

      attribute :type, :translated, scope: 'nsm.letter_and_call_type'
      adjustable_attribute :count, :integer
      adjustable_attribute :uplift, :integer
      attribute :pricing, :decimal
      attribute :adjustment_comment

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

        def adjusted_headers
          [
            t('.items', numeric: false, scope: 'nsm.letters_and_calls.adjusted'),
            t('.reason', numeric: false, scope: 'nsm.letters_and_calls.adjusted'),
            t('.number_allowed', scope: 'nsm.letters_and_calls.adjusted'),
            t('.uplift_allowed', scope: 'nsm.letters_and_calls.adjusted'),
            t('.caseworker_allowed', scope: 'nsm.letters_and_calls.adjusted')
          ]
        end

        private

        def t(key, width: nil, numeric: true, scope: 'nsm.letters_and_calls.index')
          {
            text: I18n.t(key, scope:),
            numeric: numeric,
            width: width
          }
        end
      end

      def provider_requested_amount
        calculate_cost(original: true)
      end

      def caseworker_amount
        @caseworker_amount ||= calculate_cost
      end

      def type_name
        type.to_s.downcase
      end

      def id
        type.value
      end

      def form_attributes
        attributes.except(
          'pricing', 'adjustment_comment', 'count_original', 'uplift_original'
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

      def formatted_adjusted_count
        format(count.to_s, as: :number)[:text]
      end

      def formatted_adjusted_uplift
        format(uplift.to_i, as: :number)[:text]
      end

      def formatted_adjusted_caseworker_amount
        format(caseworker_amount)[:text]
      end

      def adjusted_table_fields
        [
          type.to_s,
          adjustment_comment,
          format(count.to_s, as: :number),
          format(uplift.to_i, as: :percentage),
          format(caseworker_amount)
        ]
      end

      def provider_fields
        {
          '.number' => original_count.to_s,
          '.rate' => NumberTo.pounds(pricing),
          '.uplift_requested' => "#{original_uplift.to_i}%",
          '.total_claimed' =>  NumberTo.pounds(provider_requested_amount)
        }
      end

      def uplift?
        !original_uplift.to_i.zero?
      end

      def changed?
        provider_requested_amount != caseworker_amount
      end

      def backlink_path(claim)
        if any_adjustments?
          Rails.application.routes.url_helpers.adjusted_nsm_claim_letters_and_calls_path(claim, anchor: id)
        else
          Rails.application.routes.url_helpers.nsm_claim_letters_and_calls_path(claim, anchor: id)
        end
      end

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
