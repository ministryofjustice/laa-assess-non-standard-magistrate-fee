module PriorAuthority
  class UnassignmentsController < PriorAuthority::BaseController
    before_action :set_application, only: %i[new create]

    def new
      authorize(application, :unassign?)
      @form = UnassignmentForm.new(application_id: application.id)
    end

    def create
      local_application = PriorAuthorityApplication.find(params[:application_id])
      @form = UnassignmentForm.new(params.require(:prior_authority_unassignment_form)
                                         .permit(:comment)
                                         .merge(application_id: local_application.id))
      if @form.valid?
        assignment = local_application.assignments.first
        process_unassignment(@form.comment, local_application, assignment)
      else
        skip_authorization
        render :new
      end
    end

    private

    def process_unassignment(comment, application, assignment)
      if assignment
        PriorAuthorityApplication.transaction do
          authorize(application, :unassign?)
          ::Event::Unassignment.build(submission: application, user: assignment.user,
                                      current_user: current_user, comment: comment)
          AppStoreClient.new.unassign(application)

          assignment.destroy
        end
        redirect_to prior_authority_application_path(application)
      else
        skip_authorization
        redirect_to prior_authority_application_path(application), flash: { notice: t('.not_assigned') }
      end
    end

    def set_application
      application
    end

    def application
      @application ||= PriorAuthorityApplication.load_from_app_store(params[:application_id])
    end
  end
end
