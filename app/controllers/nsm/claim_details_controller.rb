module Nsm
  class ClaimDetailsController < ApplicationController
    def show
      claim = Claim.find(params[:claim_id])
      claim_summary = BaseViewModel.build(:claim_summary, claim)
      claim_details = ClaimDetails::Table.new(claim)

      render locals: { claim:, claim_summary:, claim_details: }
    end
  end
end
