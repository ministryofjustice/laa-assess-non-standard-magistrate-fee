class DisbursementsController < ApplicationController
  layout nil

  def index
    claim = Claim.find(params[:claim_id])
    disbursements = BaseViewModel.build_all(:disbursement, claim, 'disbursements').group_by(&:disbursement_date)
    core_cost_summary = BaseViewModel.build(:core_cost_sumamry, claim)

    render locals: { claim:, disbursements: }
  end
end
