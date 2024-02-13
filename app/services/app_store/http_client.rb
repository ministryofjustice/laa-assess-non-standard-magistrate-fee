module AppStore
  class HttpClient
    include HTTParty
    class << self
      def get_submission(submission_id)
        perform_get("/v1/submissions/#{submission_id}")
      end

      def list_submissions(params)
        perform_get('/v1/submissions', params)
      end

      def adjust_submission(submission_id, payload)
        perform_post("/v1/submissions/#{submission_id}/adjustments", payload.to_json)
      end

      def change_risk(submission_id, payload)
        perform_post("/v1/submissions/#{submission_id}/risk_changes", payload.to_json)
      end

      def change_state(submission_id, payload)
        perform_post("/v1/submissions/#{submission_id}/state_changes", payload.to_json)
      end

      def assign_submission(payload)
        perform_post('/v1/submissions/assignments', payload.to_json, return_nil_if_status: 404)
      end

      def unassign_submission(submission_id, payload)
        perform_delete("/v1/submissions/#{submission_id}/assignment", payload.to_json)
      end

      def create_note(submission_id, payload)
        perform_post("/v1/submissions/#{submission_id}/notes", payload.to_json)
      end

      private

      def perform_post(endpoint, body, return_nil_if_status: nil)
        response = post "#{host}#{endpoint}", **common_options.merge(body:)
        process_response(response, endpoint, return_nil_if_status:)
      end

      def perform_delete(endpoint, body)
        response = delete "#{host}#{endpoint}", **common_options.merge(body:)

        process_response(response, endpoint)
      end

      def perform_get(endpoint, query = nil)
        response = get "#{host}#{endpoint}", **common_options.merge(query:)

        process_response(response, endpoint)
      end

      def process_response(response, endpoint, return_nil_if_status: nil)
        case response.code
        when 200, 201
          JSON.parse(response.body) if response.body.present?
        when return_nil_if_status
          nil
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
        ENV.fetch('APP_STORE_URL', 'http://appstore.com')
      end
    end
  end
end
