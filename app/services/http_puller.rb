class HttpPuller
  include HTTParty
  headers 'Content-Type' => 'application/json'

  def get(claim)
    response = self.class.get("#{host}/v1/application/#{claim.id}", **options)

    case response.code
    when 200
      JSON.parse(response.body)
    else
      raise "Unexpected response from AppStore - status #{response.code} for '#{claim.id}'"
    end
  end

  private

  def options
    options = { }

    username = ENV.fetch('APP_STORE_USERNAME', nil)
    return options if username.blank?

    options.merge(
      basic_auth: {
        username: username,
        password: ENV.fetch('APP_STORE_PASSWORD')
      }
    )
  end

  def host
    ENV.fetch('APP_STORE_URL', 'http://localhost:8000')
  end
end
