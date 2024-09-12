module Nsm
  class LettersAndCallsAdjustmentsController < Nsm::BaseController
    def confirm_deletion
      @adjustment = adjustments.find { _1.type.values['value'] == params[:id] }
      render 'nsm/letters_and_calls/confirm_delete_adjustment',
             locals: { deletion_path: nsm_claim_letters_and_calls_adjustment_path(params[:claim_id],
                                                                                  params[:id]) }
    end

    def destroy
      Nsm::AdjustmentDeleter.new(params, :letters_and_calls, current_user).call
      redirect_to destroy_redirect, flash: { success: t('.success') }
    end

    private

    def claim
      @claim ||= Claim.find(params[:claim_id])
    end

    def destroy_redirect
      adjustments.any? ? adjusted_nsm_claim_letters_and_calls_path : nsm_claim_claim_details_path
    end

    def adjustments
      @adjustments ||= BaseViewModel
                       .build(:letter_and_call, claim, 'letters_and_calls')
                       .filter(&:any_adjustments?)
    end
  end
end
