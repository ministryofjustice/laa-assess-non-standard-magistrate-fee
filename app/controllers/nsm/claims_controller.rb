module Nsm
  class ClaimsController < ApplicationController
    def index
      claims, total = AppStoreService.list(application_type: 'crm7',
                                           assessed: false,
                                           page: params.fetch(:page, 1), count: 10)
      @claims = claims.map { |claim| BaseViewModel.build(:all_claims, claim) }
      @pagy = Pagy.new(count: total, page: params.fetch(:page, 1), size: 10)
    end

    def new
      claim = AppStoreService.assign(current_user.id, 'crm7')

      if claim
        redirect_to nsm_claim_claim_details_path(claim)
      else
        redirect_to nsm_your_claims_path, flash: { notice: t('.no_pending_claims') }
      end
    end
  end
end
