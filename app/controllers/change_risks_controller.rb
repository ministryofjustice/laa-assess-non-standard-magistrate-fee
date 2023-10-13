class ChangeRisksController < ApplicationController
  def edit
    claim = Claim.find(params[:claim_id])
    risk = ChangeRiskForm.new(id: params[:claim_id], risk_level: claim.risk)
    render locals: { claim:, risk: }
  end

  def update
    claim = Claim.find(params[:claim_id])
    risk = ChangeRiskForm.new(risk_params)

    if risk.save
      redirect_to claims_path, flash: { success: t('.success', level: risk.risk_level) }
    else
      render :edit, locals: { claim:, risk: }
    end
  end

  private

  # TODO: user current_user once merged
  def risk_params
    params.require(:change_risk_form).permit(
      :id, :risk_level, :explanation
    ).merge(current_user: User.first_or_create)
  end
end
