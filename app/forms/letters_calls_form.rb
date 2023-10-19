class LettersCallsForm
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveRecord::AttributeAssignment

  attribute :id
  attribute :type
  attribute :uplift
  attribute :count
  attribute :explanation
  attribute :current_user
  attribute :item # used to detect changes in data

  validates :claim, presence: true
  validates :type, inclusion: { in: %w[letters calls] }
  attribute :uplift, include: { in: %w[yes no] }
  validates :count, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :explanation, presence: true, if: :data_has_changed?
  validate :data_has_changed

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
      data = claim.data['letters-and_calls'].detect do |row|
        row.dig('type', 'value') == type
      end

      new_uplift = uplift == 'yes' ? 0.0 : item.provider_requested_uplift

      process_field(data, value: count, field: 'count')
      process_field(data, value: new_uplift, field: 'uplift')

      claim.save
    end
    Event::Note.build(claim:, note:, current_user:)

    true
  rescue StandardError
    false
  end

  def claim
    Claim.find_by(id:)
  end

  private

  def process_field(data, value, field)
    return if data[field] == value

    details = {
      field: field,
      from: data[field],
      to: value,
      change: value - data[field],
      comment: explanation
    }
    linked_type = type

    data[field] = values.last
    Event::Edit.build(claim:, details:, linked_type:, current_user: current_user)
  end

  def data_changed
    return if data_has_changed?

    errors.add(:base, :no_change)
  end

  def data_has_changed?
    # change to count || uplift and uplift has changed
    count != item.count || (item.uplift? && item.uplift.zero? == (uplift == 'no'))
  end
end
