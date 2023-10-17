require 'pagy/extras/array'
class ClaimsController < ApplicationController
  include Pagy::Backend
  def index
    1 / 0
    claims = Claim.pending_decision
    claims = claims.map { |claim| BaseViewModel.build(:all_claims, claim) }
    @pagy, @claims = pagy_array(claims)
  end
end
