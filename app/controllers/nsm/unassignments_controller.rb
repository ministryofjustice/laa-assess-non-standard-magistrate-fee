module Nsm
  class UnassignmentsController < Nsm::BaseController
    before_action :check_claim_assigned

    def edit
      authorize(claim, :unassign?)
      unassignment = UnassignmentForm.new(claim:, current_user:)
      render locals: { claim:, unassignment: }
    end

    def update
      authorize(claim, :unassign?)
      unassignment = UnassignmentForm.new(claim:, **send_back_params)
      if unassignment.save
        redirect_to nsm_claim_claim_details_path(claim)
      else
        render :edit, locals: { claim:, unassignment: }
      end
    end

    private

    def check_claim_assigned
      return if claim.assigned_user_id.present?

      redirect_to nsm_claim_claim_details_path(claim), flash: { notice: t('nsm.unassignments.already_unassigned') }
    end

    def claim
      @claim ||= Claim.load_from_app_store(params[:claim_id])
    end

    def send_back_params
      params.require(:nsm_unassignment_form).permit(
        :comment
      ).merge(current_user:)
    end
  end
end
