module Nsm
  class AssessedClaimsController < ApplicationController
    def index
      @pagy, claims = pagy(Claim.decision_made)
      @claims = claims.map { |claim| BaseViewModel.build(:assessed_claims, claim) }
    end
  end
end
