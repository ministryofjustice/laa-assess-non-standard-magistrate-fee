class DisbursementsForm < BaseAdjustmentForm
  DISBURSEMENT_ALLOWED = 'no'.freeze
  DISBURSEMENT_REFUSED = 'yes'.freeze

  attribute :total_cost_without_vat, :string
  validates :total_cost_without_vat, inclusion: { in: [DISBURSEMENT_ALLOWED, DISBURSEMENT_REFUSED] }

  def total_cost_without_vat=(val)
    case val
    when String then super
    when nil then nil
    else
      super(val.positive? ? 'no' : 'yes')
    end
  end

  def save
    return false unless valid?

    Claim.transaction do
      process_field(value: new_total_cost_without_vat, field: 'total_cost_without_vat')
      claim.save
    end

    true
    # TODO: uncomment once completes
    # rescue StandardError
    #   false
  end

  private

  def selected_record
    @selected_record ||= claim.data['disbursements'].detect do |row|
      row.fetch('id') == item.id
    end
  end

  def new_total_cost_without_vat
    total_cost_without_vat == 'yes' ? 0 : item.provider_requested_total_cost_without_vat
  end

  def data_has_changed?
    item.total_cost_without_vat.zero? != (total_cost_without_vat == DISBURSEMENT_REFUSED)
  end
end
