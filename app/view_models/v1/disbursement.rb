module V1
  class Disbursement < BaseViewModel
    include ActionView::Helpers::NumberHelper

    attribute :disbursement_type, :translated
    attribute :other_type, :translated
    # TODO: import time_period code from provider app
    attribute :miles, :decimal, precision: 10, scale: 3
    attribute :pricing, :decimal, precision: 10, scale: 2
    attribute :total_cost_without_vat, :decimal, precision: 10, scale: 2
    attribute :vat_rate, :decimal, precision: 3, scale: 2
    attribute :disbursement_date, :date

    def current
      CostCalculator.cost(:disbursement, self)
    end

    def requested
      current - adjustments
    end

    # TODO: calculate this fro events
    def adjustments
      0
    end

    # NOTE: This is currently designed to show values without VAT being included.
    def table_fields
      [
        other_type.to_s.presence || disbursement_type.to_s,
        number_to_currency(requested, unit: '£'),
        '£'
        # TODO: once adjustment is calculated:
        # adjustments.zero? ? '£' : number_to_currency(adjustments, unit: '£')
      ]
    end
  end
end
