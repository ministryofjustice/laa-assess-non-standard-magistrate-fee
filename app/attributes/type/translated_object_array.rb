module Type
  class TranslatedObjectArray < Type::TranslatedObject
    def type
      :translated_array
    end

    private

    def cast_value(values)
      values.map { super(_1) }
    end
  end
end
