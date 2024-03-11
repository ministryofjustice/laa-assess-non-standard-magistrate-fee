module PriorAuthority
  class AssignmentsController < PriorAuthority::BaseController
    private

    def assign_and_redirect(application, comment = nil)
      application.assignments.create!(user: current_user)
      Event::Assignment.build(submission: application, current_user: current_user, comment: comment)

      redirect_to prior_authority_application_path(application)
    end
  end
end
