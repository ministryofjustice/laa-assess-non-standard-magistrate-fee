class BaseWithAdjustments < BaseViewModel
  attribute :adjustments, default: []

  private

  def value_from_first_event(field_name)
    field = adjustments.find { |adj| adj.details['field'] == field_name }
    return unless field

    field.details['from']
  end

  def previous_explanation
    field = adjustments.last
    return unless field

    field.details['comment']
  end
end
