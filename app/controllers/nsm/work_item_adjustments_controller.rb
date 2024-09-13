module Nsm
  class WorkItemAdjustmentsController < Nsm::BaseController
    def confirm_deletion
      @adjustment = adjustments.find { _1.id == params[:id] }
      render 'nsm/work_items/confirm_delete_adjustment',
             locals: { deletion_path: nsm_claim_work_item_adjustment_path(params[:claim_id],
                                                                          params[:id]) }
    end

    def destroy
      Nsm::AdjustmentDeleter.new(params, :work_item, current_user).call
      redirect_to destroy_redirect, flash: { success: t('.success') }
    end

    private

    def claim
      @claim ||= Claim.find(params[:claim_id])
    end

    def destroy_redirect
      claim.any_adjustments? ? adjusted_nsm_claim_work_items_path : nsm_claim_claim_details_path
    end

    def adjustments
      @adjustments ||= BaseViewModel
                       .build(:work_item, claim, 'work_items')
                       .filter(&:any_adjustments?)
    end
  end
end
