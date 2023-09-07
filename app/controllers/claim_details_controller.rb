class ClaimDetailsController < ApplicationController
  def show
    claim = Claim.find(params[:claim_id])
    claim_summary = BaseViewModel.build(:claim_summary, claim)
    # TODO: move into class in next PR - outside of scope of this work
    claim_details = {
      'Details of claim' => [
        ['Unique file number', '#pending#'],
        ['Type of claim', '#pending#'],
        ['Representation order date', '#pending#'],
      ]
    }

    render locals: { claim:, claim_summary:, claim_details: }
  end
end
