module Nsm
  class DisbursementsForm < BaseAdjustmentForm
    LINKED_CLASS = V1::Disbursement
    attribute :total_cost_without_vat, :gbp
    attribute :miles, :fully_validatable_decimal, precision: 10, scale: 3
    attribute :apply_vat, :string

    validates :miles, presence: true, numericality: { greater_than_or_equal_to: 0 }, is_a_number: true, if: :mileage_based?

    def mileage_based?
      !item.miles.nil?
    end

    def apply_vat?
      apply_vat == 'true'
    end

    def save
      return false unless valid?

      if mileage_based?
        process_field(value: miles.to_f, field: 'miles')
      else
        process_field(value: total_cost_without_vat.to_f, field: 'total_cost_without_vat')
      end

      process_field(value: apply_vat, field: 'apply_vat')

      true
    end

    def vat_rate_text
      "#{(claim.rates.vat * 100).round}%"
    end

    private

    def data_has_changed?
      return true if apply_vat != item.apply_vat

      mileage_based? ? miles != item.miles : total_cost_without_vat != item.total_cost_without_vat
    end

    def explanation_required?
      true
    end

    def selected_record
      @selected_record ||= claim.data['disbursements'].detect do |row|
        row.fetch('id') == item.id
      end
    end
  end
end
