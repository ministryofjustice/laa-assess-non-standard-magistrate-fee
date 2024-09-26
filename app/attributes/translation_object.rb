class TranslationObject
  attr_reader :value, :scope

  delegate :to_s, :blank?, to: :translated

  def initialize(value, scope)
    @value = value
    @scope = scope
  end

  def ==(other)
    other.value == value && other.scope == scope
  end
  alias === ==
  alias eql? ==

  def translated
    return '' unless value

    I18n.t("laa_crime_forms_common.#{scope}.#{value}")
  end
end
