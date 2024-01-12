module NonStandardMagistratesPayment
  class AssessedClaimsController < ApplicationController
    def index
      claims = Claim.decision_made
      claims = claims.map { |claim| BaseViewModel.build(:assessed_claims, claim) }
      @pagy, @claims = pagy_array(claims)
    end
  end
end
