module PriorAuthority
  class ApplicationsController < PriorAuthority::BaseController
    def your
      applications = Claim.prior_authority.your_claims(current_user).map { PriorAuthority::Application.new(_1) }
      @pagy, @applications = pagy_array(applications)
    end

    def open
      applications = Claim.prior_authority.pending_decision.map { PriorAuthority::Application.new(_1) }
      @pagy, @applications = pagy_array(applications)
    end

    def assessed
      applications = Claim.prior_authority.decision_made.map { PriorAuthority::Application.new(_1) }
      @pagy, @applications = pagy_array(applications)
    end
  end
end
