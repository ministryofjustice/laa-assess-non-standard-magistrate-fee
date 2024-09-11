module Nsm
  class WorkItemAdjustmentsController < Nsm::BaseController
    def confirm_deletion
      @adjustment = BaseViewModel
                    .build(:work_item, claim, 'work_items')
                    .filter(&:any_adjustments?).find { _1.id == params[:id] }
      render 'nsm/work_items/confirm_delete_adjustment',
             locals: { deletion_path: nsm_claim_work_item_adjustment_path(params[:claim_id],
                                                                          params[:id]),
                       nsm_adjustments_path: adjusted_nsm_claim_work_items_path }
    end

    def destroy
      Nsm::AdjustmentDeleter.new(params, :work_item, current_user).call
      redirect_to adjusted_nsm_claim_work_items_path(params[:claim_id])
    end

    private

    def claim
      @claim ||= Claim.find(params[:claim_id])
    end
  end
end
