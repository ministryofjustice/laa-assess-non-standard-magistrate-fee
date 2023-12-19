module V1
  class LetterAndCall < BaseWithAdjustments
    LINKED_TYPE = 'letters_and_calls'.freeze
    ID_FIELDS = %w[type value].freeze

    attribute :type, :translated
    attribute :count, :integer
    attribute :uplift, :integer
    attribute :pricing, :float
    attribute :vat_rate
    attribute :firm_office

    def vat_registered?
      firm_office['vat_registered'] == 'yes'
    end

    def provider_requested_amount
      CostCalculator.cost(:letter_and_call, self, :provider_requested)
    end

    def provider_requested_amount_inc_vat
      return provider_requested_amount unless vat_registered?

      provider_requested_amount * (1 + vat_rate)
    end

    def provider_requested_uplift
      @provider_requested_uplift ||= value_from_first_event('uplift') || uplift
    end

    def provider_requested_count
      value_from_first_event('count') || count
    end

    def caseworker_amount
      @caseworker_amount ||= CostCalculator.cost(:letter_and_call, self, :caseworker)
    end

    def caseworker_amount_inc_vat
      return caseworker_amount unless vat_registered?

      caseworker_amount * (1 + vat_rate)
    end

    def caseworker_uplift
      uplift.to_i
    end

    def caseworker_count
      count
    end

    def allowed_amount
      adjustments.any? ? caseworker_amount : provider_requested_amount
    end

    def type_name
      type.to_s.downcase
    end

    def id
      type.value
    end

    def form_attributes
      attributes.slice!('pricing', 'adjustments', 'vat_rate', 'firm_office').merge(
        'type' => type.value,
        'explanation' => previous_explanation,
      )
    end

    def table_fields
      [
        type.to_s,
        count.to_s,
        "#{provider_requested_uplift.to_i}%",
        NumberTo.pounds(provider_requested_amount),
        adjustments.any? ? "#{caseworker_uplift}%" : '',
        adjustments.any? ? NumberTo.pounds(caseworker_amount) : '',
      ]
    end

    def provider_fields
      rows = {
        '.number' => provider_requested_count.to_s,
        '.rate' => NumberTo.pounds(pricing),
        '.uplift_requested' => "#{provider_requested_uplift.to_i}%",
      }

      if vat_registered?
        rows['.vat'] = NumberTo.percentage(vat_rate)
        rows['.total_claimed_inc_vate'] = NumberTo.pounds_inc_vat(provider_requested_amount_inc_vat)
      else
        rows['.total_claimed'] = NumberTo.pounds(provider_requested_amount)
      end

      rows
    end

    def uplift?
      !provider_requested_uplift.to_i.zero?
    end
  end
end
