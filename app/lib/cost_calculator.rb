module CostCalculator
  class << self
    def cost(type, object)
      case type
      when :work_item
        work_item_cost(object)
      when :letter_and_call
        letter_and_call_cost(object)
      when :disbursement
        disbursement_cost(object)
      end
    end

    private

    def work_item_cost(object)
      object.pricing * object.time_spent * (100 + object.uplift.to_i) / 100 / 60
    end

    def letter_and_call_cost(object)
      object.pricing * object.count * (100 + object.uplift.to_i) / 100
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
