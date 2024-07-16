module FileRedirectable
  extend ActiveSupport::Concern

  # 1 min expiry on pre-signed urls to keep evidence download as secure as possible
  PRESIGNED_EXPIRY = 60

  def redirect_to_file_download(s3_key, unescaped_file_name)
    file_name = unescaped_file_name.encode(Encoding.find('ISO-8859-1'), invalid: :replace, undef: :replace, replace: '')
    download_url = S3_BUCKET.object(s3_key)
                            .presigned_url(:get,
                                           expires_in: PRESIGNED_EXPIRY,
                                           response_content_disposition: "attachment; filename=\"#{file_name}\"")
    redirect_to download_url, allow_other_host: true
  end
end
