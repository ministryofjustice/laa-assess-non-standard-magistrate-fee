module PriorAuthority
  class AssignmentsController < PriorAuthority::BaseController
    def create
      # Lock to prevent two caseworkers from assigning the same application at the same time
      Assignment.with_advisory_lock('assign_user') do
        application = ChooseApplicationForAssignment.call(current_user)

        if application
          application.assignments.create!(user: current_user)
          application.update(state: 'in_progress')
          Event::Assignment.build(submission: application, current_user: current_user)

          redirect_to prior_authority_application_path(application)
        else
          redirect_to your_prior_authority_applications_path, flash: { notice: t('.no_unassigned_applications') }
        end
      end
    end
  end
end
