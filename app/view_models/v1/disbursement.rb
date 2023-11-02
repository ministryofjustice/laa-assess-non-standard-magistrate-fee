module V1
  class Disbursement < BaseWithAdjustments
    LINKED_TYPE = 'disbursements'.freeze
    ID_FIELDS = %w[id].freeze
    attribute :disbursement_type, :translated
    attribute :other_type, :translated
    # TODO: import time_period code from provider app
    attribute :miles, :decimal, precision: 10, scale: 3
    attribute :pricing, :decimal, precision: 10, scale: 2
    attribute :total_cost_without_vat, :decimal, precision: 10, scale: 2
    attribute :vat_rate, :decimal, precision: 3, scale: 2
    attribute :disbursement_date, :date
    attribute :id, :string
    attribute :details, :string
    attribute :prior_authority, :string
    attribute :apply_vat, :string
    attribute :vat_amount, :decimal, precision: 10, scale: 2

    def provider_requested_total_cost_without_vat
      value_from_first_event('total_cost_without_vat') || total_cost_without_vat
    end

    def provider_requested_total_cost
      @provider_requested_total_cost ||= CostCalculator.cost(:disbursement, self)
    end

    def caseworker_total_cost
      total_cost_without_vat.zero? ? 0 : provider_requested_total_cost
    end

    def disbursement_table_fields
      table_fields = {
        date: disbursement_date.strftime('%d %b %Y'),
        type: type_name.capitalize,
        details: details.capitalize,
        prior_authority: prior_authority.capitalize,
        vat: format_vat_rate(vat_rate),
        total: NumberTo.pounds(CostCalculator.cost(:disbursement, self))
      }
      table_fields[:miles] = miles.to_s if miles.present?
      table_fields
    end

    def format_vat_rate(rate)
      "#{(rate * 100).to_i}%"
    end

    def type_name
      other_type.to_s.presence || disbursement_type.to_s
    end

    def table_fields
      [
        type_name,
        NumberTo.pounds(provider_requested_total_cost),
        adjustments.any? ? NumberTo.pounds(caseworker_total_cost) : '',
      ]
    end
  end
end
