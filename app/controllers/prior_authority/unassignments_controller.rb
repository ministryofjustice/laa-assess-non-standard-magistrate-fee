module PriorAuthority
  class UnassignmentsController < PriorAuthority::BaseController
    def new
      authorize(application, :unassign?)
      @form = UnassignmentForm.new(application:)
    end

    def create
      authorize(application, :unassign?)
      @form = UnassignmentForm.new(params.require(:prior_authority_unassignment_form)
                                         .permit(:comment)
                                         .merge(application:))
      if @form.valid?
        process_unassignment(@form.comment)
      else
        render :new
      end
    end

    private

    def process_unassignment(comment)
      ::Event::Unassignment.build(submission: application, user: application.assigned_user,
                                  current_user: current_user, comment: comment)
      AppStoreClient.new.unassign(application)
      redirect_to prior_authority_application_path(application)
    end

    def application
      @application ||= PriorAuthorityApplication.load_from_app_store(params[:application_id])
    end
  end
end
