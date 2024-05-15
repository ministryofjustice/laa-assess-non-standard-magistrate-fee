module Nsm
  class ClaimsController < ApplicationController
    def your
      claims = Claim.pending_and_assigned_to(current_user)
      pagy, filtered_claims = pagy(claims)
      your_claims = filtered_claims.map { |claim| BaseViewModel.build(:your_claims, claim) }

      render locals: { your_claims:, pagy: }
    end

    def open
      @pagy, claims = pagy(Claim.pending_decision)
      @claims = claims.map { |claim| BaseViewModel.build(:all_claims, claim) }
    end

    def closed
      @pagy, claims = pagy(Claim.decision_made)
      @claims = claims.map { |claim| BaseViewModel.build(:assessed_claims, claim) }
    end

    def new
      claim = Claim.unassigned(current_user).order(created_at: :desc).first

      if claim
        Claim.transaction do
          claim.assignments.create!(user: current_user)
          ::Event::Assignment.build(submission: claim, current_user: current_user)
        end

        redirect_to nsm_claim_claim_details_path(claim)
      else
        redirect_to your_nsm_claims_path, flash: { notice: t('.no_pending_claims') }
      end
    end
  end
end
