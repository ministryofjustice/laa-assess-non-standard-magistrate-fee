module Nsm
  class ChangeRisksController < Nsm::BaseController
    def edit
      authorize(claim)
      risk = ChangeRiskForm.new(claim: claim, risk_level: claim.risk)
      render locals: { claim:, risk: }
    end

    def update
      authorize(claim)
      risk = ChangeRiskForm.new(risk_params)

      if risk.save
        redirect_to nsm_claim_claim_details_path(params[:claim_id]),
                    flash: { success: t('.success', level: risk.risk_level) }
      else
        render :edit, locals: { claim:, risk: }
      end
    end

    private

    def claim
      @claim ||= Claim.load_from_app_store(params[:claim_id])
    end

    def risk_params
      params.require(:nsm_change_risk_form).permit(
        :risk_level, :explanation
      ).merge(current_user:, claim:)
    end
  end
end
