class MakeDecisionsController < ApplicationController
  def edit
    decision = MakeDecisionForm.new(id: params[:claim_id])
    render locals: { claim:, decision: }
  end

  # TODO: put some sort of permissions here for non supervisors?
  def update
    decision = MakeDecisionForm.new(decision_params)
    if decision.save
      reference = BaseViewModel.build(:laa_reference, claim)
      success_notice = t(
        ".decision.#{decision.state}",
        ref: reference.laa_reference,
        url: claim_claim_details_path(claim.id)
      )
      redirect_to assessed_claims_path, flash: { success: success_notice }
    else
      render :edit, locals: { claim:, decision: }
    end
  end

  private

  def claim
    @claim ||= Claim.find(params[:claim_id])
  end

  # TODO: user current_user once merged
  def decision_params
    params.require(:make_decision_form).permit(
      :state, :partial_comment, :reject_comment, :id
    ).merge(current_user: current_user)
  end
end
