class SupportingEvidencesController < ApplicationController
  def show
    claim = Claim.find(params[:claim_id])
    claim_summary = BaseViewModel.build(:claim_summary, claim)
    supporting_evidence = BaseViewModel.build(:supporting_evidence, claim, 'supporting_evidences')

    generate_urls supporting_evidence

    @pagy, @supporting_evidence = pagy_array(supporting_evidence)
    render locals: { claim:, claim_summary: }
  end

  private

  def generate_urls(supporting_evidence)
    supporting_evidence.each do | item |
      item.download_url = S3_BUCKET
                          .object(item.file_path)
                          .presigned_url(:get, expires_in: 900,
                                         response_content_disposition: "attachment; filename=#{item.file_name}")
    end
  end
end
