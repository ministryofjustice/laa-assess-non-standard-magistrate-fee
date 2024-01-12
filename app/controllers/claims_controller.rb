class ClaimsController < ApplicationController
  def index
    claims = Claim.non_standard_mags.pending_decision
    claims = claims.map { |claim| BaseViewModel.build(:all_claims, claim) }
    @pagy, @claims = pagy_array(claims)
  end

  def new
    claim = Claim.non_standard_mags.unassigned_claims(current_user).order(created_at: :desc).first

    if claim
      Claim.transaction do
        claim.assignments.create!(user: current_user)
        Event::Assignment.build(claim:, current_user:)
      end

      redirect_to claim_claim_details_path(claim)
    else
      redirect_to your_claims_path, flash: { notice: t('.no_pending_claims') }
    end
  end
end
