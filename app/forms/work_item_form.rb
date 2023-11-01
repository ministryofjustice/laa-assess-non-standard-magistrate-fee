class WorkItemForm < BaseAdjustmentForm
  UPLIFT_PROVIDED = 'no'.freeze
  UPLIFT_RESET = 'yes'.freeze

  attribute :id, :string
  attribute :work_type, :string
  attribute :uplift, :string
  # not set to integer so we can catch errors if non-number values are entered
  attribute :time_spent

  validates :type, inclusion: { in: %w[travel waiting advocacy preparation attendance_with_counsel attendance_without_counsel] }
  validates :uplift, inclusion: { in: [UPLIFT_PROVIDED, UPLIFT_RESET] }, if: -> { item.uplift? }
  validates :time_spent, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  # overwrite uplift setter to allow value to be passed as either string (form)
  # or integer (initial setup) value
  def uplift=(val)
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
      process_field(value: time_spent.to_i, field: 'time_spent')
      process_field(value: new_uplift, field: 'uplift')

      claim.save
    end

    true
  rescue StandardError
    false
  end

  private

  def selected_record
    @selected_record ||= claim.data['work_items'].detect do |row|
      row.fetch('id') == item.id
    end
  end

  def new_uplift
    uplift == 'yes' ? 0 : item.provider_requested_uplift
  end

  def data_has_changed?
    count.to_i != item.count ||
      (item.uplift? && item.uplift.zero? != (uplift == UPLIFT_RESET))
  end
end
