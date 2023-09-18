module Type
  class TranslatedObject < ActiveModel::Type::Value
    def type
      :translated
    end

    def serialize(value)
      value.hash
    end

    private

    def cast_value(value)
      return if value.nil?
      raise 'invalid_type' unless value.is_a?(Hash)

      TranslationObject.new(value)
    end
  end
end
