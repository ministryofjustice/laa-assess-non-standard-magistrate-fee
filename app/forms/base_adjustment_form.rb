class BaseAdjustmentForm
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveRecord::AttributeAssignment

  attribute :submission
  attribute :explanation, :string
  attribute :current_user
  attribute :item # used to detect changes in data

  validates :explanation, presence: true, if: :explanation_required?
  validate :data_changed

  private

  def process_field(value:, field:, comment_field: 'adjustment_comment')
    return if selected_record[field] == value

    # does this belong in the Event object as that is where it is
    # created for everything else? as that would require passing a
    # lot of varibles across....
    details = {
      field: field,
      from: selected_record[field],
      to: value,
      comment: explanation,
    }.merge(changed_value(value, selected_record[field]))

    ensure_original_field_value_set(field)
    assign_new_attributes(field, value, comment_field)

    Event::Edit.build(submission:, details:, linked:, current_user:)
  end

  def ensure_original_field_value_set(field)
    selected_record["#{field}_original"] ||= selected_record[field]
  end

  def assign_new_attributes(field, value, comment_field)
    selected_record[field] = value
    selected_record[comment_field] = explanation
  end

  def changed_value(val1, val2)
    return { change: val1 - val2 } if val1.respond_to?(:-) && val2.respond_to?(:-)

    {}
  end

  def linked
    {
      type: self.class::LINKED_CLASS::LINKED_TYPE,
      id: selected_record.dig(*self.class::LINKED_CLASS::ID_FIELDS),
    }
  end

  def data_changed
    return if data_has_changed?

    errors.add(:base, :no_change)
  end

  def explanation_required?
    data_has_changed?
  end

  # :nocov:
  def data_has_changed?
    raise 'implement in class'
  end

  def selected_record
    raise 'implement in class'
  end
  # :nocov:
end
