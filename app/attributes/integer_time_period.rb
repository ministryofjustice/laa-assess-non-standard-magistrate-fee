class IntegerTimePeriod < SimpleDelegator
  delegate :nil?, to: :__getobj__

  def hours
    return nil if __getobj__.nil?

    __getobj__ / 60
  end

  def minutes
    return nil if __getobj__.nil?

    __getobj__ % 60
  end

  # The default behaviour when coerced with a decimal
  # is to convert both to floats, which can introduce floating point
  # rounding errors. This corrects that.
  def coerce(arg)
    return [arg, to_d] if arg.is_a?(BigDecimal)

    super(arg)
  end
end
