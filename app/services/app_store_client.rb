class AppStoreClient
  include HTTParty
  headers 'Content-Type' => 'application/json'

  def get_submission(submission_id)
    process(:get, "/v1/application/#{submission_id}")
  end

  def get_all_submissions(last_update)
    process(:get, "/v1/applications?since=#{last_update.to_i}")
  end

  def update_submission(payload)
    response = self.class.put("#{host}/v1/application/#{payload[:application_id]}", **options(payload))

    case response.code
    when 201
      :success
    when 409
      # can be ignored but should be notified so we can track when it occurs
      Sentry.capture_message("Application ID already exists in AppStore for '#{payload[:application_id]}'")
      :warning
    else
      raise "Unexpected response from AppStore - status #{response.code} for '#{payload[:application_id]}'"
    end
  end

  def create_subscription(payload)
    response = self.class.post("#{host}/v1/subscriber", **options(payload))

    case response.code
    when 200..204
      :success
    else
      raise "Unexpected response from AppStore - status #{response.code} on create subscription"
    end
  end

  private

  def process(method, url)
    response = self.class.public_send(method, "#{host}#{url}", **options)

    case response.code
    when 200
      JSON.parse(response.body)
    else
      raise "Unexpected response from AppStore - status #{response.code} for '#{url}'"
    end
  end

  def options(payload = nil)
    options = payload ? { body: payload.to_json } : {}

    return options unless AppStoreTokenProvider.instance.authentication_configured?

    token = AppStoreTokenProvider.instance.bearer_token

    options.merge(
      headers: {
        authorization: "Bearer #{token}"
      }
    )
  end

  def host
    ENV.fetch('APP_STORE_URL', 'http://localhost:8000')
  end
end
