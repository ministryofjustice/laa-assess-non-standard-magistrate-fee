module Nsm
  class SupportingEvidencesController < Nsm::BaseController
    # 15 min expiry on pre-signed urls to keep evidence download as secure as possible
    PRESIGNED_EXPIRY = 900

    def show
      claim = Claim.find(params[:claim_id])
      claim_summary = BaseViewModel.build(:claim_summary, claim)
      supporting_evidence = BaseViewModel.build(:supporting_evidence, claim, 'supporting_evidences')
      @pagy, @supporting_evidence = pagy_array(supporting_evidence)
      render locals: { claim:, claim_summary: }
    end
  end
end
