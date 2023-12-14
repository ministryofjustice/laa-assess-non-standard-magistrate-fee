module NumberTo
  extend ActionView::Helpers::NumberHelper

  def self.pounds(*values, round_mode: :half_up)
    value = values.any?(&:nil?) ? nil : values.sum
    return '£' unless value

    number_to_currency(value, unit: '£')
  end

  def self.pounds_inc_vat(*values)
    pounds(*values, round_mode: :down)
  end

  def self.percentage(value, decimals: 0)
    "#{(value * 100).round(decimals)}%"
  end
end
