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

  def reduced?
    provider_requested_amount > caseworker_amount
  end

  def increased?
    provider_requested_amount < caseworker_amount
  end
end
