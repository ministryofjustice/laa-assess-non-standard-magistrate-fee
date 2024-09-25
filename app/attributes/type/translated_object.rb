module Type
  class TranslatedObject < ActiveModel::Type::Value
    def initialize(*args, **kwargs)
      @scope = kwargs.delete(:scope)
      super
    end

    def type
      :translated
    end

    private

    def cast_value(value)
      key = value.is_a?(Hash) ? value['value'] : value
      TranslationObject.new(key, @scope)
    end
  end
end
