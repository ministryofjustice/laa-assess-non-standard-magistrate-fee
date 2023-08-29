class ClaimsController < ApplicationController
  def index
  end

  def show
    claim = Claim.find(params[:id])
    claim_summary = ClaimSummary.build(claim.current_version_record.data)

    render locals: { claim:, claim_summary: }
  end
end