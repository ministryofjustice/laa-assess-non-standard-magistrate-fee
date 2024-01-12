module NonStandardMagistratesPayment
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
          Event::Assignment.build(crime_application: claim, current_user: current_user)
        end

        redirect_to non_standard_magistrates_payment_claim_claim_details_path(claim)
      else
        redirect_to non_standard_magistrates_payment_your_claims_path, flash: { notice: t('.no_pending_claims') }
      end
    end
  end
end