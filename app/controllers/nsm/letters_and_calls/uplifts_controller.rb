module Nsm
  module LettersAndCalls
    class UpliftsController < ApplicationController
      def edit
        claim = Claim.find(params[:claim_id])
        form = Uplift::LettersAndCallsForm.new(claim:)

        render locals: { claim:, form: }
      end

      def update
        claim = Claim.find(params[:claim_id])
        form = Uplift::LettersAndCallsForm.new(claim:, **form_params)

        if form.save
          redirect_to nsm_claim_adjustments_path(claim, anchor: 'letters-and-calls-tab'),
                      flash: { success: t('.uplift_removed') }
        else
          render :edit, locals: { claim:, form: }
        end
      end

      private

      def form_params
        params.require(:nsm_uplift_letters_and_calls_form)
              .permit(:explanation)
              .merge(current_user:)
      end
    end
  end
end
