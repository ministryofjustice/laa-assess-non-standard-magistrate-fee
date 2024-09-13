module Nsm
  class DisbursementAdjustmentsController < Nsm::BaseController
    def confirm_deletion
      @adjustment = adjustments.find { _1.id == params[:id] }
      render 'nsm/disbursements/confirm_delete_adjustment',
             locals: { deletion_path: nsm_claim_disbursement_adjustment_path(params[:claim_id],
                                                                             params[:id]) }
    end

    def destroy
      Nsm::AdjustmentDeleter.new(params, :disbursement, current_user).call
      redirect_to destroy_redirect, flash: { success: t('.success') }
    end

    private

    def claim
      @claim ||= Claim.find(params[:claim_id])
    end

    def destroy_redirect
      claim.any_adjustments? ? adjusted_nsm_claim_disbursements_path : nsm_claim_claim_details_path
    end

    def adjustments
      @adjustments ||= BaseViewModel
                       .build(:disbursement, claim, 'disbursements')
                       .filter(&:any_adjustments?)
    end
  end
end
