module Nsm
  class DisbursementAdjustmentsController < Nsm::BaseController
    def confirm_deletion
      @adjustment = BaseViewModel
                    .build(:disbursement, claim, 'disbursements')
                    .filter(&:any_adjustments?).find { _1.id == params[:id] }
      render 'nsm/disbursements/confirm_delete_adjustment',
             locals: { cost_item_type: t('.disbursement'),
                       deletion_path: nsm_claim_disbursement_adjustment_path(params[:claim_id],
                                                                             params[:id]),
                       nsm_adjustments_path: adjusted_nsm_claim_disbursements_path }
    end

    def destroy
      Nsm::AdjustmentDeleter.new(params, :disbursement, current_user).call
      redirect_to adjusted_nsm_claim_disbursements_path(params[:claim_id])
    end

    private

    def claim
      @claim ||= Claim.find(params[:claim_id])
    end
  end
end
