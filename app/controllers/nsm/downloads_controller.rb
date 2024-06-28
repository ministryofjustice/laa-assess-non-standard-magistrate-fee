module Nsm
  class DownloadsController < Nsm::BaseController
    # 1 min expiry on pre-signed urls to keep evidence download as secure as possible
    PRESIGNED_EXPIRY = 60

    def show
      claim = Claim.find(params[:claim_id])
      supporting_evidence = BaseViewModel.build(:supporting_evidence, claim, 'supporting_evidences')
      item = supporting_evidence.detect { _1.id == params[:id] }
      download_url = S3_BUCKET.object(item.file_path)
                              .presigned_url(:get,
                                             expires_in: PRESIGNED_EXPIRY,
                                             response_content_disposition: "attachment; filename=\"#{item.file_name}\"")
      redirect_to download_url, allow_other_host: true
    end
  end
end
