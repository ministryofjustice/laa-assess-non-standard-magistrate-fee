module Type
  class TranslatedObject < ActiveModel::Type::Value
    def type
      :translated
    end

    def serialize(_value)
      raise 'Value cannot be re-serialized'
    end

    private

    def cast_value(value)
      raise 'Invalid Type' unless value.is_a?(Hash)

      TranslationObject.new(value)
    end
  end
end
