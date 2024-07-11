class AppStoreClient
  include HTTParty
  headers 'Content-Type' => 'application/json'

  def get_all_submissions(last_update)
    url = "/v1/applications?since=#{last_update.to_i}"
    response = self.class.get "#{host}#{url}", **options

    case response.code
    when 200
      JSON.parse(response.body)
    else
      raise "Unexpected response from AppStore - status #{response.code} for '#{url}'"
    end
  end

  def get_submission(submission)
    url = "/v1/submissions/#{submission.id}"
    response = self.class.get "#{host}#{url}", **options

    case response.code
    when 200
      JSON.parse(response.body)
    else
      raise "Unexpected response from AppStore - status #{response.code} for '#{url}'"
    end
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

  def trigger_subscription(payload, action: :create)
    method = action == :create ? :post : :delete
    response = self.class.send(method, "#{host}/v1/subscriber", **options(payload))

    case response.code
    when 200..204
      :success
    else
      raise "Unexpected response from AppStore - status #{response.code} on #{action} subscription"
    end
  end

  def create_events(submission_id, payload)
    response = self.class.post("#{host}/v1/submissions/#{submission_id}/events", **options(payload))

    case response.code
    when 200..204
      :success
    when 403
      :forbidden
    else
      raise "Unexpected response from AppStore - status #{response.code} on create events"
    end
  end

  private

  def options(payload = nil)
    options = payload ? { body: payload.to_json } : {}
    options.merge(headers:)
  end

  def headers
    if AppStoreTokenProvider.instance.authentication_configured?
      token = AppStoreTokenProvider.instance.bearer_token

      { authorization: "Bearer #{token}" }
    else
      { 'X-Client-Type': 'caseworker' }
    end
  end

  def host
    ENV.fetch('APP_STORE_URL', 'http://localhost:8000')
  end
end
