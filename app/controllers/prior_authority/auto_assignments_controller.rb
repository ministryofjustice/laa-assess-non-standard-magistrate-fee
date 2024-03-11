module PriorAuthority
  class AutoAssignmentsController < PriorAuthority::AssignmentsController
    def create
      # Lock to prevent two caseworkers from assigning the same application at the same time
      Assignment.with_advisory_lock('assign_user') do
        application = ChooseApplicationForAssignment.call(current_user)

        if application
          assign_and_redirect(application)
        else
          redirect_to your_prior_authority_applications_path, flash: { notice: t('.no_unassigned_applications') }
        end
      end
    end
  end
end
