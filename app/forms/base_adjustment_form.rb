class BaseAdjustmentForm
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveRecord::AttributeAssignment

  attribute :submission
  attribute :explanation, :string
  attribute :current_user
  attribute :item # used to detect changes in data
  validate :data_changed

  def save!
    submission.with_lock do
      AppStoreClient.new.adjust(submission) if save
    end
  end

  private

  COMMENT_FIELD = 'adjustment_comment'.freeze

  def process_field(value:, field:)
    selected_record[self.class::COMMENT_FIELD] = explanation

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
    assign_new_attributes(field, value)

    Event::Edit.build(submission:, details:, linked:, current_user:)
  end

  def ensure_original_field_value_set(field)
    selected_record["#{field}_original"] ||= selected_record[field]
  end

  def assign_new_attributes(field, value)
    selected_record[field] = value
  end

  def changed_value(val1, val2)
    return { change: val1 - val2 } if val1.respond_to?(:-) && val2.respond_to?(:-)

    {}
  end

  def linked
    {
      type: self.class::LINKED_CLASS::LINKED_TYPE,
      id: linked_id(selected_record),
    }
  end

  def linked_id(row)
    row['id']
  end

  def data_changed
    return if data_has_changed? || explanation_has_changed?

    errors.add(no_change_field, :no_change)
  end

  def no_change_field
    :base
  end

  def explanation_required?
    data_has_changed?
  end

  def explanation_has_changed?
    return false if selected_record[self.class::COMMENT_FIELD].blank?

    explanation != selected_record[self.class::COMMENT_FIELD]
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
