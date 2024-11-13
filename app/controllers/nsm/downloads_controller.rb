module Nsm
  class DownloadsController < Nsm::BaseController
    include FileRedirectable

    def show
      claim = Claim.load_from_app_store(params[:claim_id])
      authorize claim
      supporting_evidence = BaseViewModel.build(:supporting_evidence, claim, 'supporting_evidences')
      item = supporting_evidence.detect { _1.id == params[:id] }
      redirect_to_file_download(item.file_path, item.file_name)
    end
  end
end
