module Type
  class FullyValidatableDecimal < ActiveModel::Type::Decimal
    def cast(value)
      if value.is_a?(Numeric) || value.blank? || value.strip.gsub(/[0-9,\.-]/, '').empty?
        super(value&.to_s&.delete(','))
      else
        # If the user has entered a string that is not straightforwardly parseable
        # as a decimal, retain the original value so we can display it back to the user
        value
      end
    end
  end
end
