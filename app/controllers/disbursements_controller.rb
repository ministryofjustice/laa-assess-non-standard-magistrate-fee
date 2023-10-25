class DisbursementsController < ApplicationController
  layout nil

  def index
    claim = Claim.find(params[:claim_id])
    disbursements = BaseViewModel.build(:disbursement, claim, 'disbursements').group_by(&:disbursement_date)

    render locals: { claim:, disbursements: }
  end
end
