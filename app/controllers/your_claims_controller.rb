class YourClaimsController < ApplicationController
  def index
    claims = Claim.your_claims
    claims = claims.map { |claim| BaseViewModel.build(:your_claims, claim) }
    @pagy, @claims = pagy_array(claims)
    # TODO: Next claim assignment needs to be done
    @next_claim = Claim.unassigned_claims.order(created_at: :desc).first
  end
end
