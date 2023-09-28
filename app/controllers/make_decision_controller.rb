class MakeDecisionController < ApplicationController
  def index
    claim = Claim.find(params[:claim_id])
    render locals: { claim: }
  end
end
