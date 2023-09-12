module NumberHelper
  extend ActionView::Helpers::NumberHelper

  def pounds(*values)
    value = values.any?(&:nil?) ? nil : values.sum
    return '£' unless value

    number_to_currency(value, unit: '£')
  end
end