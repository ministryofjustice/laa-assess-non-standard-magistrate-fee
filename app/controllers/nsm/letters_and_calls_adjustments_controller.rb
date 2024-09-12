module Nsm
  class LettersAndCallsAdjustmentsController < Nsm::BaseController
    def confirm_deletion
      @adjustment = BaseViewModel
                    .build(:letter_and_call, claim, 'letters_and_calls')
                    .filter(&:any_adjustments?)
                    .find { _1.type.values['value'] == params[:id] }
      render 'nsm/letters_and_calls/confirm_delete_adjustment',
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

    def claim
      @claim ||= Claim.find(params[:claim_id])
    end
  end
end
