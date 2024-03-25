module PriorAuthority
  class UnassignmentsController < PriorAuthority::BaseController
    def new
      @form = UnassignmentForm.new application_id: params[:application_id]
    end

    def create
      @form = UnassignmentForm.new(params.require(:prior_authority_unassignment_form).permit(:comment).merge(
                                     application_id: params[:application_id]
                                   ))
      if @form.valid?
        application = PriorAuthorityApplication.find(params[:application_id])
        assignment = application.assignments.first
        process_unassignment(@form.comment, application, assignment)
      else
        render :new
      end
    end

    private

    def process_unassignment(comment, application, assignment)
      if assignment
        PriorAuthorityApplication.transaction do
          ::Event::Unassignment.build(submission: application, user: assignment.user,
                                      current_user: current_user, comment: comment)

          assignment.destroy
        end
        redirect_to prior_authority_application_path(application)
      else
        redirect_to prior_authority_application_path(application), flash: { notice: t('.not_assigned') }
      end
    end
  end
end
