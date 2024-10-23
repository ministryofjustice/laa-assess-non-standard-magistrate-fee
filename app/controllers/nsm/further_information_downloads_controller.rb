module Nsm
  class FurtherInformationDownloadsController < Nsm::BaseController
    include FileRedirectable

    def show
      authorize Claim, :show?
      redirect_to_file_download(params[:id], params[:file_name])
    end
  end
end
