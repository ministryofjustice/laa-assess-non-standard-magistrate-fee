if ENV.fetch('LOCALSTACK', false)
  Aws.config.update(
    region: ENV.fetch('AWS_REGION', 'eu-west-2'),
    endpoint: 'https://localhost.localstack.cloud:4566',
    force_path_style: true
  )
elsif ENV.fetch('STUB_AWS_RESPONSES', false)
  Aws.config.update(stub_responses: true)
else
  Aws.config.update(
    region: ENV.fetch('AWS_REGION', 'eu-west-2')
  )
end

S3_BUCKET = Aws::S3::Resource.new.bucket(ENV.fetch('S3_BUCKET', 'default'))
