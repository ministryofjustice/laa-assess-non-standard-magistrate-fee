class Claim < Submission
  default_scope -> { where(application_type: APPLICATION_TYPES[:nsm]) }

  STATES = (
    [
      SUBMITTED = 'submitted'.freeze,
      SENT_BACK = 'sent_back'.freeze,
      PROVIDER_UPDATED = 'provider_updated'.freeze,
    ] +
      CLOSED_STATES = (
        (ASSESSED_STATES = [
          GRANTED = 'granted'.freeze,
          PART_GRANT = 'part_grant'.freeze,
          REJECTED = 'rejected'.freeze
        ].freeze) +
        [EXPIRED = 'expired'.freeze]
      ).freeze
  ).freeze

  enum :state, STATES.to_h { [_1, _1] }

  def assigned_to?(user)
    assignments.find_by(user:)
  end

  def assessed?
    ASSESSED_STATES.include?(state)
  end

  def closed?
    CLOSED_STATES.include?(state)
  end

  def formatted_claimed_total
    formatted_summed_costs.dig(:gross_cost, :text)
  end

  def formatted_allowed_total
    return formatted_claimed_total if formatted_summed_costs[:allowed_gross_cost].blank? || granted_and_allowed_less_than_claim

    formatted_summed_costs.dig(:allowed_gross_cost, :text)
  end

  def any_adjustments?
    core_cost_summary.show_allowed?
  end

  def any_cost_changes?
    core_cost_summary.any_changed?
  end

  def any_cost_reductions?
    core_cost_summary.any_reduced?
  end

  def any_cost_increases?
    core_cost_summary.any_increased?
  end

  def adjustments_direction
    return :none unless any_cost_changes?
    return :mixed if any_cost_increases? && any_cost_reductions?
    return :down if any_cost_reductions?

    :up
  end

  def totals
    @totals ||= LaaCrimeFormsCommon::Pricing::Nsm.totals(data_for_calculation)
  end

  def rates
    @rates ||= LaaCrimeFormsCommon::Pricing::Nsm.rates(data_for_calculation)
  end

  def data_for_calculation
    {
      claim_type: BaseViewModel.build(:details_of_claim, self).claim_type.value,
      rep_order_date: data['rep_order_date'],
      cntp_date: data['cntp_date'],
      vat_registered: data.dig('firm_office', 'vat_registered') == 'yes',
      work_items: work_items_for_calculation,
      disbursements: disbursements_for_calculation,
      letters_and_calls: letters_and_calls_for_calculation,
    }
  end

  private

  def granted_and_allowed_less_than_claim
    allowed_gross_cost = totals.dig(:totals, :assessed_total_inc_vat)
    gross_cost = totals.dig(:totals, :claimed_total_inc_vat)

    granted? && allowed_gross_cost < gross_cost
  end

  def formatted_summed_costs
    @formatted_summed_costs ||= core_cost_summary.formatted_summed_fields
  end

  def core_cost_summary
    @core_cost_summary ||= BaseViewModel.build(:core_cost_summary, self)
  end

  def work_items_for_calculation
    BaseViewModel.build(:work_item, self, 'work_items').map(&:data_for_calculation)
  end

  def disbursements_for_calculation
    BaseViewModel.build(:disbursement, self, 'disbursements').map(&:data_for_calculation)
  end

  def letters_and_calls_for_calculation
    BaseViewModel.build(:letter_and_call, self, 'letters_and_calls').map(&:data_for_calculation)
  end
end
