module NumberTo
  extend ActionView::Helpers::NumberHelper

  def self.pounds(*values, round_mode: :half_up)
    value = values.any?(&:nil?) ? nil : values.sum
    return '£' unless value

    number_to_currency(value, unit: '£', round_mode: round_mode)
  end

  def self.pounds_inc_vat(*)
    pounds(*, round_mode: :down)
  end

  def self.percentage(value, decimals: 0, multiplier: 100)
    "#{(value * multiplier).round(decimals)}%"
  end
end
