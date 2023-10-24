module V1
  class LetterAndCall < BaseViewModel
    LINKED_TYPE = %w[letters calls].freeze

    attribute :type, :translated
    attribute :count, :integer
    attribute :uplift, :integer
    attribute :pricing, :float
    attribute :adjustments, default: []

    def provider_requested_amount
      CostCalculator.cost(:letter_and_call, self, :provider_requested)
    end

    def provider_requested_uplift
      @provider_requested_uplift ||= value_from_first_event('uplift') || uplift.to_i
    end

    def provider_requested_count
      value_from_first_event('count') || count
    end

    def caseworker_amount
      @caseworker_amount ||= CostCalculator.cost(:letter_and_call, self, :caseworker)
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

    def form_attributes
      attributes.slice!('pricing', 'adjustments').merge('type' => type.value)
    end

    def table_fields
      [
        type.to_s,
        count.to_s,
        "#{provider_requested_uplift}%",
        NumberTo.pounds(provider_requested_amount),
        adjustments.any? ? "#{caseworker_uplift}%" : '',
        adjustments.any? ? NumberTo.pounds(caseworker_amount) : '',
      ]
    end

    def uplift?
      !provider_requested_uplift.to_i.zero?
    end

    def value_from_first_event(field_name)
      field = adjustments.filter { |adj| adj.details['field'] == field_name }.first
      return unless field

      field.details['from']
    end
  end
end
