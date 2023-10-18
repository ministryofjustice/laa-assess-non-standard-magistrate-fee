class SupportingEvidencesController < ApplicationController
  def show
    claim = Claim.find(params[:claim_id])
    claim_summary = BaseViewModel.build(:claim_summary, claim)
    supporting_evidence = BaseViewModel.build_all(:supporting_evidence, claim, 'supporting_evidences')

    @pagy, @supporting_evidence = pagy_array(supporting_evidence)
    render locals: { claim:, claim_summary: }
  end
end
