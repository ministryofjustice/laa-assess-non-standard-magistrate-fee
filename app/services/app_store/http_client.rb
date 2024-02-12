module AppStore
  class HttpClient
    include HTTParty
    headers 'Content-Type' => 'application/json'

    def get_submission(submission_id)
      get("/v1/submissions/#{submission_id}")
    end

    def list_submissions(params)
      get('/v1/submissions', params)
    end

    def update_submission(submission_id, payload)
      patch("/v1/submissions/#{submission_id}", payload.to_json)
    end

    def assign_submission(payload)
      post('/v1/submissions/assignments', payload.to_json)
    end

    def unassign_submission(submission_id, payload)
      delete("/v1/submissions/#{submission_id}/assignment", payload.to_json)
    end

    private

    def patch(endpoint, body)
      response = self.class.patch "#{host}#{endpoint}", **common_options.merge(body:)

      case response.code
      when 200, 201
        true
      else
        raise "Unexpected response from AppStore - status #{response.code} for '#{endpoint}'"
      end
    end

    def post(endpoint, body)
      response = self.class.post "#{host}#{endpoint}", **common_options.merge(body:)

      case response.code
      when 201
        JSON.parse(response.body)
      when 404
        nil
      else
        raise "Unexpected response from AppStore - status #{response.code} for '#{endpoint}'"
      end
    end

    def delete(endpoint, body)
      response = self.class.delete "#{host}#{endpoint}", **common_options.merge(body:)

      case response.code
      when 200
        true
      else
        raise "Unexpected response from AppStore - status #{response.code} for '#{endpoint}'"
      end
    end

    def get(endpoint, query = nil)
      response = self.class.get "#{host}#{endpoint}", **common_options.merge(query:)

      case response.code
      when 200
        JSON.parse(response.body)
      else
        raise "Unexpected response from AppStore - status #{response.code} for '#{endpoint}'"
      end
    end

    def common_options
      token = TokenProvider.instance.bearer_token

      {
        headers: {
          authorization: "Bearer #{token}",
          'Content-Type': 'application/json'
        }
      }
    end

    def host
      ENV.fetch('APP_STORE_URL', 'http://localhost:8000')
    end
  end
end
