module FileRedirectable
  extend ActiveSupport::Concern

  def redirect_to_file_download(s3_key, unescaped_file_name)
    download_url = LaaCrimeFormsCommon::S3Files.temporary_download_url(
      S3_BUCKET,
      s3_key,
      unescaped_file_name
    )
    redirect_to download_url, allow_other_host: true
  end
end
