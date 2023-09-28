class SendBackController < ApplicationController
  def index
    claim = Claim.find(params[:claim_id])
    claim_summary = BaseViewModel.build(:claim_summary, claim)
    render locals: { claim_summary: }
  end
end
