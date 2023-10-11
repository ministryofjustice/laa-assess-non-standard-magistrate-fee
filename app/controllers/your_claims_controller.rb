require 'pagy/extras/array'
class YourClaimsController < ApplicationController
  include Pagy::Backend
  def index
    claims = Claim.your_claims
    claims = claims.map { |claim| BaseViewModel.build(:your_claims, claim) }
    @pagy, @claims = pagy_array(claims)
  end
end
