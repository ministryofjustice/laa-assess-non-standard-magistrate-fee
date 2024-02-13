module StubHelpers
  def stub_api_request(method, url, response: nil, status: 200, body: nil)
    stub_request(method, "http://appstore.com#{url}")
      .with(
        headers: {
          'Accept' => '*/*',
           'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
           'Authorization' => 'Bearer token',
           'Content-Type' => 'application/json',
           'User-Agent' => 'Ruby'
        },
        body: (body.to_json if body)
      )
      .to_return(status: status, body: response&.to_json, headers: {})
  end
end
