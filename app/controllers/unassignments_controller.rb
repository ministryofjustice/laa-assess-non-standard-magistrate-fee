class UnassignmentsController < ApplicationController
  def edit
    unassignment = UnassignmentForm.new(claim:, current_user:)
    render locals: { claim:, unassignment: }
  end

  # TODO: put some sort of permissions here for non supervisors?
  def update
    unassignment = UnassignmentForm.new(claim:, **send_back_params)
    if unassignment.save
      reference = BaseViewModel.build(:laa_reference, claim)
      success_notice = t(
        ".unassignment.#{unassignment.unassignment_user}",
        ref: reference.laa_reference,
        url: claim_claim_details_path(claim.id),
        caseworker: unassignment.user.display_name
      )
      redirect_to your_claims_path, flash: { success: success_notice }
    else
      render :edit, locals: { claim:, unassignment: }
    end
  end

  private

  def claim
    @claim ||= Claim.find(params[:claim_id])
  end

  def send_back_params
    params.require(:unassignment_form).permit(
      :comment
    ).merge(current_user:)
  end
end
