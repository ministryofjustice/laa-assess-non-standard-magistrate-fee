module V1
  class LetterAndCall < BaseViewModel
    attribute :type, :translated
    attribute :count, :integer
    attribute :uplift, :integer
    attribute :pricing, :float

    def provider_requested_amount
      CostCalculator.cost(:letter_and_call, self)
    end

    def allowed_uplift
      '#pending#'
    end

    def adjustment
      '#pending#'
    end

    def uplift_amount
      uplift.nil? ? '0%' : "#{uplift}%"
    end

    def table_fields
      [type.to_s, count.to_s, uplift_amount, NumberTo.pounds(provider_requested_amount), allowed_uplift, adjustment]
    end
  end
end
