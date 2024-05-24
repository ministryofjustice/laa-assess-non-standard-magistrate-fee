module Nsm
  class DisbursementsForm < BaseAdjustmentForm
    LINKED_CLASS = V1::Disbursement
    attribute :total_cost_without_vat, :gbp
    attribute :miles, :fully_validatable_decimal, precision: 10, scale: 3
    attribute :apply_vat, :string
    attribute :vat_rate, :decimal, precision: 10, scale: 3

    validates :miles, presence: true, numericality: { greater_than_or_equal_to: 0 }, is_a_number: true, if: :mileage_based?

    def mileage_based?
      !item.miles.nil?
    end

    def apply_vat?
      apply_vat == 'true'
    end

    def save
      return false unless valid?

      Claim.transaction do
        if mileage_based?
          process_field(value: miles.to_f, field: 'miles')
          process_field(value: calculated_total_cost_without_vat.to_f, field: 'total_cost_without_vat')
        else
          process_field(value: total_cost_without_vat.to_f, field: 'total_cost_without_vat')
        end

        process_field(value: apply_vat, field: 'apply_vat')
        process_field(value: calculated_vat_amount, field: 'vat_amount')
        claim.save
      end

      true
    end

    def vat_rate_text
      "#{(item.vat_rate * 100).round}%"
    end

    private

    def calculated_total_cost_without_vat
      miles * item.pricing
    end

    def calculated_vat_amount
      return 0 unless apply_vat?

      pre_vat = mileage_based? ? calculated_total_cost_without_vat : total_cost_without_vat

      pre_vat * item.vat_rate
    end

    def data_has_changed?
      return true if apply_vat != item.original_apply_vat

      mileage_based? ? miles != item.original_miles : total_cost_without_vat != item.original_total_cost_without_vat
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
