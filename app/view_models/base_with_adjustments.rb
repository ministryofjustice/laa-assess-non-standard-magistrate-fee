class BaseWithAdjustments < BaseViewModel
  attribute :adjustment_comment

  def self.adjustable_attribute(attribute_name, type, options = {})
    attribute attribute_name, type, **options
    attribute :"#{attribute_name}_original", type, **options
    define_method :"original_#{attribute_name}" do
      attributes["#{attribute_name}_original"] || attributes[attribute_name.to_s]
    end
  end

  def any_adjustments?
    adjustment_comment.present?
  end

  # private

  # def value_from_first_event(field_name)
  #   field_event_for(field_name, 'from')
  # end
  # alias adjusted_from_value_for value_from_first_event

  # def value_to_first_event(field_name)
  #   field_event_for(field_name, 'to', :desc)
  # end
  # alias adjusted_to_value_for value_to_first_event

  # def field_event_for(field_name, origin = 'from', order = nil)
  #   sorted = adjustments.sort_by!(&:created_at)
  #   sorted.reverse! if order == :desc
  #   field = sorted.find { |adj| adj.details['field'] == field_name }

  #   return unless field

  #   field.details[origin]
  # end
end
