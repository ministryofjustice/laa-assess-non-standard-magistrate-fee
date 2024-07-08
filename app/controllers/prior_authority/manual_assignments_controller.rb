module PriorAuthority
  class ManualAssignmentsController < PriorAuthority::AssignmentsController
    before_action :set_application, only: %i[new create]

    def new
      @form = ManualAssignmentForm.new
    end

    def create
      @form = ManualAssignmentForm.new(params.require(:prior_authority_manual_assignment_form).permit(:comment))
      if @form.valid?
        process_assignment(@form.comment)
      else
        render :new
      end
    end

    private

    def process_assignment(comment)
      application.with_lock do
        if application.assignments.none?
          assign_and_redirect(application, comment)
        else
          redirect_to prior_authority_application_path(application), flash: { notice: t('.already_assigned') }
        end
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
