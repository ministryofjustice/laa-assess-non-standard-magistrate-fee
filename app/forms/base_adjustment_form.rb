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
    AppStoreClient.new.adjust(submission) if save
  end

  private

  COMMENT_FIELD = 'adjustment_comment'.freeze

  def process_field(value:, field:)
    selected_record[self.class::COMMENT_FIELD] = explanation

    return if selected_record[field] == value

    ensure_original_field_value_set(field)
    assign_new_attributes(field, value)
  end

  def ensure_original_field_value_set(field)
    selected_record["#{field}_original"] ||= selected_record[field]
  end

  def assign_new_attributes(field, value)
    selected_record[field] = value
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
