module Nsm
  class YourClaimsController < ApplicationController
    def index
      claims, total = AppStoreService.list(application_type: 'crm7',
                                           assessed: false,
                                           assigned_user_id: current_user.id,
                                           page: params.fetch(:page, 1),
                                           count: 10)

      your_claims = claims.map { |claim| BaseViewModel.build(:your_claims, claim) }
      pagy = Pagy.new(count: total, page: params.fetch(:page, 1), size: 10)

      render locals: { your_claims:, pagy: }
    end
  end
end
