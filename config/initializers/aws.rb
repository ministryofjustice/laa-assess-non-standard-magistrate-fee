if Rails.env.development? && ENV.fetch('LOCALSTACK', false)
  Aws.config.update({
                      region: ENV.fetch('AWS_REGION', 'eu-west-2'),
                      endpoint: 'https://localhost.localstack.cloud:4566',
                      force_path_style: true
                    })

  S3_BUCKET = Aws::S3::Resource.new.bucket(ENV.fetch('S3_BUCKET', 'default'))
end

if Rails.env.production?
  Aws.config.update({
                      region: ENV.fetch('AWS_REGION', 'eu-west-2'),
                      force_path_style: true
                    })

  S3_BUCKET = Aws::S3::Resource.new.bucket(ENV.fetch('S3_BUCKET', 'default'))
end

if Rails.env.test?
  Aws.config.update(stub_responses: true)
  S3_BUCKET = Aws::S3::Resource.new.bucket('test')
end
