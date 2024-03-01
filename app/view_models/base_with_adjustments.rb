class BaseWithAdjustments < BaseViewModel
  attribute :adjustment_events, default: []

  def self.adjustable_attribute(attribute_name, type, options = {})
    attribute attribute_name, type, **options
    attribute :"#{attribute_name}_original", type, **options
    define_method :"original_#{attribute_name}" do
      attributes["#{attribute_name}_original"] || attributes[attribute_name.to_s]
    end
  end

  def any_adjustments?
    attributes.any? { |name, value| name.end_with?('_original') && value.present? }
  end

  def previous_explanation
    field = adjustment_events.last
    return unless field

    field.details['comment']
  end
end
