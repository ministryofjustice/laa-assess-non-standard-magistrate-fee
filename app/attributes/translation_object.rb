class TranslationObject
  attr_reader :values

  delegate :to_s, :blank?, to: :value

  def initialize(values)
    @values = values
  end

  def ==(other)
    other.is_a?(self.class) && other.values['value'] == values['value']
  end
  alias === ==
  alias eql? ==

  def value
    values[I18n.locale.to_s] || values['value']
  end
end
