require 'pagy/extras/array'
class SupportingEvidencesController < ApplicationController
  include Pagy::Backend

  DEFAULT_PAGE_SIZE = 5
  def show
    claim = Claim.find(params[:claim_id])
    claim_summary = BaseViewModel.build(:claim_summary, claim)
    supporting_evidence = BaseViewModel.build_all(:supporting_evidence, claim, 'supporting_evidences')
    @pagy, @supporting_evidence = pagy_array(
      supporting_evidence,
      items: params.fetch(:page_size, DEFAULT_PAGE_SIZE)
    )
    render locals: { claim:, claim_summary:, supporting_evidence: }
  end
end
