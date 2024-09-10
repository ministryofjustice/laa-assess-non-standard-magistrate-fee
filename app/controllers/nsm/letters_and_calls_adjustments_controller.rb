module Nsm
  class LettersAndCallsAdjustmentsController < Nsm::BaseController
    def confirm_deletion
      render 'nsm/shared/confirm_delete_adjustment',
             locals: { item_name: t('.letters_and_calls'),
                       deletion_path: nsm_claim_letters_and_calls_adjustment_path(params[:claim_id],
                                                                                  params[:id]),
                       nsm_adjustments_path: adjusted_nsm_claim_letters_and_calls_path }
    end

    def destroy
      Nsm::AdjustmentDeleter.new(params, :letters_and_calls, current_user).call
      redirect_to adjusted_nsm_claim_letters_and_calls_path(params[:claim_id])
    end

    private

    def safe_params
      # :id, :claims_id
    end
  end
end
