class ClaimsController < ApplicationController
  def index
    claims = Claim.pending_decision
    claims = claims.map { |claim| BaseViewModel.build(:all_claims, claim) }
    @pagy, @claims = pagy_array(claims)
  end

  def new
    claim = Claim.unassigned_claims(current_user).order(created_at: :desc).first

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

  def destroy
    claim = Claim.find(params[:id])

    Claim.transaction do
      claim.current_assignments.each do |assignment|
        Event::Unassignment.build(
          claim: claim,
          user: assignment.user,
          current_user: current_user
        )
      end
      claim.current_assignments.update_all(end_at: Time.now)
    end

    redirect_to your_claims_path
  end
end
