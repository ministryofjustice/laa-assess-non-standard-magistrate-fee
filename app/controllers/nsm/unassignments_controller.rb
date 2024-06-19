module Nsm
  class UnassignmentsController < Nsm::BaseController
    def edit
      unassignment = UnassignmentForm.new(claim:, current_user:)
      render locals: { claim:, unassignment: }
    end

    # TODO: put some sort of permissions here for non supervisors?
    def update
      unassignment = UnassignmentForm.new(claim:, **send_back_params)
      if unassignment.save
        redirect_to nsm_claim_claim_details_path(claim)
      else
        render :edit, locals: { claim:, unassignment: }
      end
    end

    private

    def claim
      @claim ||= Claim.find(params[:claim_id])
    end

    def send_back_params
      params.require(:nsm_unassignment_form).permit(
        :comment
      ).merge(current_user:)
    end
  end
end
