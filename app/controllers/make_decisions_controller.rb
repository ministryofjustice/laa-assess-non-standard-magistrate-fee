class MakeDecisionsController < ApplicationController
  def edit
    claim = Claim.find(params[:claim_id])
    decision = MakeDecisionForm.new(id: params[:claim_id])
    render locals: { claim:, decision: }
  end

  def update
    claim = Claim.find(params[:claim_id])
    decision = MakeDecisionForm.new(decision_params)
    if decision.save
      redierect_to claims_path, flash: { success: 'claim success text' }
    else
      render :edit, locals: { claim:, decision: }
    end
  end

  private

  def decision_params
    params.require(:make_decision_form).permit(
      :state, :partial_comment, :reject_comment, :id
    )
  end
end
