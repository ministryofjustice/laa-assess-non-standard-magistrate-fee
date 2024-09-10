module Nsm
  class DisbursementAdjustmentsController < Nsm::BaseController
    def confirm_deletion
      render 'nsm/shared/confirm_delete_adjustment',
             locals: { item_name: t('.disbursement'),
                       deletion_path: nsm_claim_disbursement_adjustment_path(params[:claim_id],
                                                                             params[:id]),
                       nsm_adjustments_path: adjusted_nsm_claim_disbursements_path }
    end

    def destroy
      Nsm::AdjustmentDeleter.new(params, :disbursement, current_user).call
      redirect_to adjusted_nsm_claim_disbursements_path(params[:claim_id])
    end

    private

    def safe_params
    end
  end
end
