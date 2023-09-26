require 'pagy/extras/array'
class ClaimsController < ApplicationController
  include Pagy::Backend
  def index
    claims = Claim.all
    claims = claims.map { |claim| BaseViewModel.build(:all_claims, claim) }
    @pagy, @claims = pagy_array(claims)
  end
end
