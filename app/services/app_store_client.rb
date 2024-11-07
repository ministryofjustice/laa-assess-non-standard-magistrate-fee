class AppStoreClient
  include HTTParty
  headers 'Content-Type' => 'application/json'

  def get_all_submissions(last_update)
    url = "/v1/applications?since=#{last_update.to_i}"
    response = self.class.get "#{host}#{url}", **options

    process_response(
      response,
      "Unexpected response from AppStore - status #{response.code} for '#{url}'",
      200 => ->(body) { JSON.parse(body) },
    )
  end

  def get_submission(submission)
    url = "/v1/submissions/#{submission.id}"
    response = self.class.get "#{host}#{url}", **options

    process_response(
      response,
      "Unexpected response from AppStore - status #{response.code} for '#{url}'",
      200 => ->(body) { JSON.parse(body) },
    )
  end

  def update_submission(payload)
    response = self.class.put("#{host}/v1/application/#{payload[:application_id]}", **options(payload))

    process_response(
      response,
      "Unexpected response from AppStore - status #{response.code} for '#{payload[:application_id]}'",
      201 => :success,
      409 => lambda do |_|
        # can be ignored but should be notified so we can track when it occurs
        Sentry.capture_message("Application ID already exists in AppStore for '#{payload[:application_id]}'")
        :warning
      end
    )
  end

  def update_submission_metadata(submission, payload)
    response = self.class.patch("#{host}/v1/submissions/#{submission.id}/metadata", **options(payload))

    process_response(
      response,
      "Unexpected response from AppStore - status #{response.code} for metadata update to'#{submission.id}'",
      200 => :success,
    )
  end

  def trigger_subscription(payload, action: :create)
    method = action == :create ? :post : :delete
    response = self.class.send(method, "#{host}/v1/subscriber", **options(payload))

    process_response(
      response,
      "Unexpected response from AppStore - status #{response.code} on #{action} subscription",
      200..204 => :success,
    )
  end

  def create_events(submission_id, payload)
    response = self.class.post("#{host}/v1/submissions/#{submission_id}/events", **options(payload))

    process_response(
      response,
      "Unexpected response from AppStore - status #{response.code} on create events",
      200..204 => :success,
      403 => :forbidden,
    )
  end

  def search(payload)
    response = self.class.post("#{host}/v1/submissions/searches", **options(payload))

    process_response(
      response,
      "Unexpected response from AppStore - status #{response.code} for search:\n#{response.body}",
      201 => ->(body) { JSON.parse(body) },
    )
  end

  def assign(submission, user)
    response = self.class.post("#{host}/v1/submissions/#{submission.id}/assignment", **options(caseworker_id: user.id))
    process_response(
      response,
      "Unexpected response from AppStore - status #{response.code} for assignment to :#{submission.id}",
      201 => :created,
    )
  end

  def unassign(submission)
    response = self.class.delete("#{host}/v1/submissions/#{submission.id}/assignment", **options)
    process_response(
      response,
      "Unexpected response from AppStore - status #{response.code} for assignment to :#{submission.id}",
      204 => :deleted,
    )
  end

  def auto_assign(application_type, current_user_id)
    response = self.class.post("#{host}/v1/submissions/auto_assignments", **options(application_type:, current_user_id:))
    process_response(
      response,
      "Unexpected response from AppStore - status #{response.code} for auto-assignment",
      201 => ->(body) { JSON.parse(body) },
      404 => ->(body) {},
    )
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

  def process_response(response, error_message, response_maps)
    outcome = response_maps.detect { _1[0] == response.code || (_1[0].is_a?(Range) && _1[0].include?(response.code)) }&.last

    raise error_message unless outcome

    if outcome.respond_to?(:call)
      outcome.call(response.body)
    else
      outcome
    end
  end
end
