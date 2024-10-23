module PriorAuthority
  class DownloadsController < BaseController
    include FileRedirectable

    def show
      authorize(PriorAuthorityApplication, :show?)
      redirect_to_file_download(params[:id], params[:file_name])
    end
  end
end
