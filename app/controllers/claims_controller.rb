class ClaimsController < ApplicationVersionsController
  def index
  end

  def show
    claim = Claim.find(params[:id])
    claim_summary = ClaimSummary.new(claim.current_version.data)

    render locals: { claim:, claim_summary: }
  end
end