module PriorAuthority
  class ManualAssignmentsController < PriorAuthority::AssignmentsController
    before_action :set_application, only: %i[new create]

    def new
      authorize(application, :assign?)
      @form = ManualAssignmentForm.new
    end

    def create
      local_application = PriorAuthorityApplication.find(params[:application_id])
      authorize(local_application, :assign?)
      @form = ManualAssignmentForm.new(params.require(:prior_authority_manual_assignment_form).permit(:comment))
      if @form.valid?
        process_assignment(local_application, @form.comment)
      else
        render :new
      end
    end

    private

    def process_assignment(local_application, comment)
      local_application.with_lock do
        if local_application.assignments.none?
          assign_and_redirect(local_application, comment)
        else
          redirect_to prior_authority_application_path(local_application), flash: { notice: t('.already_assigned') }
        end
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
