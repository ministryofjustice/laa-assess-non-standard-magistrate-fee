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
      raise 'invalid_type' unless value.is_a?(Hash)

      TranslationObject.new(value)
    end
  end

  class TranslationObject
    attr_reader :values
    delegate :to_s, :blank?, to: :value

    def initialize(values)
      @values = values
    end

    def value
      values[I18n.locale.to_s] || values['value']
    end
  end
end
