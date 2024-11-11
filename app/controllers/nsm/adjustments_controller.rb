module Nsm
  class AdjustmentsController < Nsm::BaseController
    def confirm_deletion
      authorize Claim.load_from_app_store(params[:claim_id]), :update?
      form = DeleteAdjustmentsForm.new

      render :confirm_deletion_adjustments, locals: { deletion_path:, form: }
    end

    def delete_all
      form = DeleteAdjustmentsForm.new(**safe_params)
      deleter = Nsm::AllAdjustmentsDeleter.new(params, nil, current_user)
      authorize deleter.submission, :update?

      if form.valid?
        deleter.call!
        redirect_to nsm_claim_claim_details_path, flash: { success: t('.success') }
      else
        render :confirm_deletion_adjustments, locals: { deletion_path:, form: }
      end
    end

    private

    def deletion_path
      delete_all_nsm_claim_adjustments_path(params[:claim_id])
    end

    def safe_params
      params.require(:nsm_delete_adjustments_form).permit(:comment)
    end
  end
end
