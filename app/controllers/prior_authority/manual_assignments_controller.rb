module PriorAuthority
  class ManualAssignmentsController < PriorAuthority::AssignmentsController
    def new
      authorize(application, :assign?)
      @form = ManualAssignmentForm.new
    end

    def create
      authorize(application, :assign?)
      @form = ManualAssignmentForm.new(params.require(:prior_authority_manual_assignment_form).permit(:comment))
      if @form.valid?
        process_assignment(@form.comment)
      else
        render :new
      end
    end

    private

    def process_assignment(comment)
      if application.assigned_user_id.nil?
        assign_and_redirect(application, comment)
      else
        redirect_to prior_authority_application_path(application), flash: { notice: t('.already_assigned') }
      end
    end

    def application
      @application ||= PriorAuthorityApplication.load_from_app_store(params[:application_id])
    end
  end
end
