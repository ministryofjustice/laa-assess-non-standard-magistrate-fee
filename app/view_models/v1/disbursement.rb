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
    attribute :apply_vat, :boolean

    def current
      CostCalculator.cost(:disbursement, self)
    end

    def provider_requested_total_cost_without_vat
      value_from_first_event('total_cost_without_vat') || total_cost_without_vat
    end

    def requested
      current - adjustments
    end

    # TODO: calculate this fro events
    def adjustments
      0
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
    # NOTE: This is currently designed to show values without VAT being included.

    def table_fields
      [
        type_name,
        NumberTo.pounds(requested),
        '£'
        # TODO: once adjustment is calculated:
        # adjustments.zero? ? '£' : NumberTo.pounds(adjustments)
      ]
    end
  end
end
