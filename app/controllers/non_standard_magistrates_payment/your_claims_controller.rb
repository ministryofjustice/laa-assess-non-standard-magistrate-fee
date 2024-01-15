module NonStandardMagistratesPayment
  class YourClaimsController < ApplicationController
    def index
      claims = Claim.pending_and_assigned_to(current_user)
      pagy, filtered_claims = pagy_array(claims)
      your_claims = filtered_claims.map { |claim| BaseViewModel.build(:your_claims, claim) }

      render locals: { your_claims:, pagy: }
    end
  end
end
