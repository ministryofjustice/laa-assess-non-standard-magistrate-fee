module PriorAuthority
  class ApplicationsController < PriorAuthority::BaseController
    def your
      applications = PriorAuthorityApplication.pending_and_assigned_to(current_user).map do |application|
        PriorAuthority::Application.new(application)
      end

      @pagy, @applications = pagy_array(applications)
    end

    # TODO: Implement these views
    # def open
    #   applications = PriorAuthorityApplication.pending_decision.map { PriorAuthority::Application.new(_1) }
    #   @pagy, @applications = pagy_array(applications)
    # end

    # def assessed
    #   applications = PriorAuthorityApplication.decision_made.map { PriorAuthority::Application.new(_1) }
    #   @pagy, @applications = pagy_array(applications)
    # end
  end
end
