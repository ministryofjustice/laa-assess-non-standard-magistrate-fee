class YourClaimsController < ApplicationController
  def index
    claims = Claim.your_claims(current_user)
    claims = claims.map { |claim| BaseViewModel.build(:your_claims, claim) }
    @pagy, @claims = pagy_array(claims)
  end
end
