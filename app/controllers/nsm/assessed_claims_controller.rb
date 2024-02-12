module Nsm
  class AssessedClaimsController < ApplicationController
    def index
      claims, total = AppStoreService.list(application_type: 'crm7',
                                           assessed: true,
                                           page: params.fetch(:page, 1),
                                           count: 10)
      @claims = claims.map { |claim| BaseViewModel.build(:assessed_claims, claim) }
      @pagy = Pagy.new(count: total, page: params.fetch(:page, 1), size: 10)
    end
  end
end
