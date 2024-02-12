module Nsm
  class ChangeRisksController < ApplicationController
    def edit
      claim = AppStoreService.get(params[:claim_id])
      risk = ChangeRiskForm.new(id: params[:claim_id], risk_level: claim.risk)
      render locals: { claim:, risk: }
    end

    def update
      claim = AppStoreService.get(params[:claim_id])
      risk = ChangeRiskForm.new(risk_params)

      if risk.save
        redirect_to nsm_claim_claim_details_path(params[:claim_id]),
                    flash: { success: t('.success', level: risk.risk_level) }
      else
        render :edit, locals: { claim:, risk: }
      end
    end

    private

    def risk_params
      params.require(:nsm_change_risk_form).permit(
        :id, :risk_level, :explanation
      ).merge(current_user:)
    end
  end
end
