module PriorAuthority
  class UnassignmentsController < PriorAuthority::BaseController
    before_action :set_application, only: %i[new create]

    def new
      authorize(application, :unassign?)
      @form = UnassignmentForm.new(application_id: application.id)
    end

    def create
      @form = UnassignmentForm.new(params.require(:prior_authority_unassignment_form)
                                         .permit(:comment)
                                         .merge(application_id: application.id))
      if @form.valid?
        assignment = application.assignments.first
        process_unassignment(@form.comment, application, assignment)
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
      @application ||= PriorAuthorityApplication.find(params[:application_id])
    end
  end
end
