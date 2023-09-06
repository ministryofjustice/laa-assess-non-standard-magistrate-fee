require 'rails_helper'

RSpec.describe HttpPuller do
  let(:response) { double(:response, code:, body:) }
  let(:code) { 200 }
  let(:body) { { some: :data }.to_json }
  let(:username) { nil }
  let(:claim) { instance_double(Claim, id: SecureRandom.uuid) }

  before do
    allow(described_class).to receive(:get)
      .and_return(response)
    allow(ENV).to receive(:fetch).and_call_original
    allow(ENV).to receive(:fetch).with('APP_STORE_USERNAME', nil)
                                 .and_return(username)
  end

  context 'when APP_STORE_URL is present' do
    before do
      allow(ENV).to receive(:fetch).with('APP_STORE_URL', 'http://localhost:8000')
                                   .and_return('http://some.url')
    end

    it 'get the claims to the specified URL' do
      expect(described_class).to receive(:get).with("http://some.url/v1/application/#{claim.id}")

      subject.get(claim)
    end
  end

  context 'when APP_STORE_URL is not present' do
    it 'get the claims to default localhost url' do
      expect(described_class).to receive(:get).with("http://localhost:8000/v1/application/#{claim.id}")

      subject.get(claim)
    end
  end

  context 'when APP_STORE_USERNAME is present' do
    let(:username) { 'jimbob' }

    before do
      allow(ENV).to receive(:fetch).with('APP_STORE_PASSWORD')
                                   .and_return('kimbob')
    end

    it 'add basic auth creditals' do
      expect(described_class).to receive(:get).with("http://localhost:8000/v1/application/#{claim.id}",
                                                    basic_auth: { username: 'jimbob', password: 'kimbob' },)

      subject.get(claim)
    end
  end

  context 'when response code is 200 - ok' do
    it 'returns the parsed json' do
      expect(subject.get(claim)).to eq('some' => 'data')
    end
  end

  context 'when response code is unexpected (neither 201 or 209)' do
    let(:code) { 501 }

    it 'raises and error' do
      expect { subject.get(claim) }.to raise_error(
        "Unexpected response from AppStore - status 501 for '#{claim.id}'"
      )
    end
  end
end
