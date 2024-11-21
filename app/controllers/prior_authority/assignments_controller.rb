module PriorAuthority
  class AssignmentsController < PriorAuthority::BaseController
    private

    def assign_and_redirect(application, comment = nil, tell_app_store: true)
      AppStoreClient.new.assign(application, current_user) if tell_app_store
      ::Event::Assignment.build(submission: application, current_user: current_user, comment: comment)

      redirect_to prior_authority_application_path(application)
    end
  end
end
