class ClaimsController < ApplicationController
  def index
    claims = Claim.all
    claims = claims.map { |claim| BaseViewModel.build(:all_claims, claim) }
    render locals: { claims: }
  end
end
