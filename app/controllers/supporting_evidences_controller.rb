class SupportingEvidencesController < ApplicationController
  def show
    claim = Claim.find(params[:claim_id])
    claim_summary = BaseViewModel.build(:claim_summary, claim)

    render locals: { claim:, claim_summary: }
  end
end
