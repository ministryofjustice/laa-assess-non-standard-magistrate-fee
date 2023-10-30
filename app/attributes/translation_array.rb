class TranslationArray
  attr_reader :values

  def initialize(values)
    @values = values
  end

  def ==(other)
    other.is_a?(self.class) && other.value == value
  end
  alias === ==
  alias eql? ==

  def translated
    values.map { |row| row[I18n.locale.to_s] || row['value'] }
  end

  def value
    values.map { |row| row['value'] }
  end

  def to_s
    translated
  end
end
