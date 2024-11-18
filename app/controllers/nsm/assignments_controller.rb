module Nsm
  class AssignmentsController < Nsm::BaseController
    include AssignmentConcern

    def new
      authorize claim, :self_assign?
      @form = AssignmentForm.new
    end

    def create
      authorize(claim, :self_assign?)
      @form = AssignmentForm.new(params.require(:nsm_assignment_form).permit(:comment))
      if @form.valid?
        process_assignment(@form.comment)
      else
        render :new
      end
    end

    private

    def claim
      @claim ||= Claim.load_from_app_store(params[:claim_id])
    end

    def process_assignment(comment)
      assign(claim, comment:)
      redirect_to nsm_claim_claim_details_path(claim)
    end
  end
end
