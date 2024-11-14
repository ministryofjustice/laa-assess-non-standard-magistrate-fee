module PriorAuthority
  class AutoAssignmentsController < PriorAuthority::AssignmentsController
    def create
      authorize PriorAuthorityApplication, :assign?
      data = AppStoreClient.new.auto_assign(Submission::APPLICATION_TYPES[:prior_authority], current_user.id)
      if data
        application = PriorAuthorityApplication.rehydrate(data)
        assign_and_redirect(application, tell_app_store: false)
      else
        redirect_to your_prior_authority_applications_path, flash: { notice: t('.no_unassigned_applications') }
      end
    end
  end
end
