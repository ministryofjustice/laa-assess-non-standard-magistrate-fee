module CostCalculator
  def self.cost(type, object)
    case type
    when :work_item
      object.pricing * object.time_spent * (100 + object.uplift.to_i) / 100 / 60
    when :letter_and_call
      object.pricing * object.count * (100 + object.uplift.to_i) / 100
    end
  end
end
