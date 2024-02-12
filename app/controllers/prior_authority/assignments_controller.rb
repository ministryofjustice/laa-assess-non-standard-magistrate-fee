module PriorAuthority
  class AssignmentsController < PriorAuthority::BaseController
    def create
      application = AppStoreService.assign(current_user.id, 'crm4')
      if application
        redirect_to prior_authority_application_path(application)
      else
        redirect_to your_prior_authority_applications_path, flash: { notice: t('.no_unassigned_applications') }
      end
    end
  end
end
