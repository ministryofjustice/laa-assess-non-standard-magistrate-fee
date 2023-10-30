module Type
  class TranslatedObject < ActiveModel::Type::Value
    attr_reader :array

    def initialize(*args, **kwargs)
      @array = kwargs.delete(:array)
      super
    end

    def type
      :translated
    end

    def serialize(_value)
      raise 'Value cannot be re-serialized'
    end

    private

    def cast_value(value)
      if array
        raise "Invalid Type for #{value.inspect}" unless value.is_a?(Array) && value.all? { |row| row.is_a?(Hash) }

        TranslationArray.new(value)
      else
        raise "Invalid Type for #{value.inspect}" unless value.is_a?(Hash)

        TranslationObject.new(value)
      end
    end
  end
end
