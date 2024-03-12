class Autograntable
  attr_reader :submission, :reason

  def initialize(submission:)
    @submission = submission
  end

  def grantable?
    return fail_with_reason(:version) unless submission.current_version == 1
    return fail_with_reason(:additional_costs) if additional_costs.any?
    return fail_with_reason(:unknown_service) unless limits
    return fail_with_reason(:exceed_service_costs) unless below_service_cost_limit?
    return fail_with_reason(:exceed_travel_costs) unless below_travel_cost_limit?

    return true
  end

  def below_service_cost_limit?
    if quote.cost_type == 'per_hour' && limits.unit_type == 'hours'
      limits.max_units >= quote.period && max_rate >= quote.cost_per_hour
    elsif quote.cost_type == 'per_item' && limits.unit_type == 'items'
      limits.max_units >= quote.items && max_rate >= quote.cost_per_item
    else
      false
    end
  end

  def fail_with_reason(reason)
    @reason = reason
    false
  end

  def below_travel_cost_limit?
    return true if quote.travel_time.zero?

    (limits.travel_hours * 60) >= quote.travel_time && max_travel_rate >= quote.travel_cost_per_hour
  end

  def max_travel_rate
    london? ? limits.travel_rate_london : limits.travel_rate_non_london
  end

  def max_rate
    london? ? limits.max_rate_london : limits.max_rate_non_london
  end

  def london?
    true
  end

  def limits
    @limits ||= AutograntLimit.order(start_date: :desc).find_by(service:, start_date:)
  end

  def quote
    PriorAuthority::V1::Quote.new(
      submission.data['quotes'].find { _1['primary'] }
    )
  end

  private

  def additional_costs
    submission.data['additional_costs']
  end

  def service
    submission.data['service_type']
  end

  def start_date
    date =
      if submission.data['prison_law']
        _, day, month, year = submission.data['prison_law'].ufn.match(%r{\A(\d{2})(\d{2})(\d{2})/})
        Date.new(2000 + year.to_i, month.to_i, day.to_i)
      else
        submission.data['rep_order_date']
      end

    (..date)
  end
end
