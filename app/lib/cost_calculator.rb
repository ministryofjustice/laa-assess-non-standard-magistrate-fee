module CostCalculator
  class << self
    def cost(type, object, scope = nil)
      case type
      when :work_item
        work_item_cost(object, scope)
      when :letter_and_call
        letter_and_call_cost(object, scope)
      when :disbursement
        disbursement_cost(object)
      end
    end

    private

    def work_item_cost(object, scope)
      object.pricing * object["#{scope}_time_spent"] * (100 + object["#{scope}_uplift"].to_i) / 100 / 60
    end

    def letter_and_call_cost(object, scope)
      object.pricing * object["#{scope}_count"] * (100 + object["#{scope}_uplift"].to_i) / 100
    end

    def disbursement_cost(object)
      if object.disbursement_type.value == 'other'
        object.total_cost_without_vat
      else
        object.miles * object.pricing
      end
    end
  end
end
