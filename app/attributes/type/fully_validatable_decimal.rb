module Type
  class FullyValidatableDecimal < ActiveModel::Type::Decimal
    def cast(value)
      if suitable_for_casting?(value)
        super(value&.to_s&.strip&.delete(','))
      else
        # If the user has entered a string that is not straightforwardly parseable
        # as a decimal, retain the original value so we can display it back to the user
        value
      end
    end

    def suitable_for_casting?(value)
      return true if value.is_a?(Numeric) || value.blank?
      return false unless value.strip.gsub(/[0-9,\.-]/, '').empty?

      uncommad = value.to_s.delete(',').strip
      uncommad =~ /^[0-9]+(\.[0-9]+)?$/
    end
  end
end
