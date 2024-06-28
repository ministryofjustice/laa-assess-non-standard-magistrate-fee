module PriorAuthority
  class DownloadsController < BaseController
    # 1 min expiry on pre-signed urls to keep evidence download as secure as possible
    PRESIGNED_EXPIRY = 60

    def show
      download_url = S3_BUCKET.object(params[:id])
                              .presigned_url(:get,
                                             expires_in: PRESIGNED_EXPIRY,
                                             response_content_disposition: "attachment; filename=\"#{params[:file_name]}\"")
      redirect_to download_url, allow_other_host: true
    end
  end
end
