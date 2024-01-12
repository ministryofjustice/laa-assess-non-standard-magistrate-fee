module PriorAuthority
  class ApplicationsController < PriorAuthority::BaseController
    def your
      applications = PriorAuthorityApplication.your_claims(current_user).map { PriorAuthority::Application.new(_1) }
      @pagy, @applications = pagy_array(applications)
    end

    def open
      applications = PriorAuthorityApplication.pending_decision.map { PriorAuthority::Application.new(_1) }
      @pagy, @applications = pagy_array(applications)
    end

    def assessed
      applications = PriorAuthorityApplication.decision_made.map { PriorAuthority::Application.new(_1) }
      @pagy, @applications = pagy_array(applications)
    end
  end
end
