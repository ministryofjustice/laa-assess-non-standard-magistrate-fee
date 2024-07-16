require 'rails_helper'

RSpec.describe NotifyEventAppStore do
  subject { described_class.new }

  let(:event) { instance_double(Event, submission_id:, as_json:) }
  let(:submission_id) { SecureRandom.uuid }
  let(:as_json) { { event: :json } }

  describe '#perform' do
    let(:http_notifier) { instance_double(AppStoreClient, create_events: true) }

    before do
      allow(AppStoreClient).to receive(:new).and_return(http_notifier)
    end

    it 'creates a new AppStoreClient instance' do
      expect(AppStoreClient).to receive(:new)

      subject.perform(event:)
    end

    it 'sends a HTTP message' do
      expect(http_notifier).to receive(:create_events).with(submission_id, events: [as_json])

      subject.perform(event:)
    end

    describe 'when error during notify process' do
      before do
        allow(http_notifier).to receive(:create_events).and_raise('annoying_error')
      end

      it 'allows the error to be raised - should reset the sidekiq job' do
        expect { subject.perform(event:) }.to raise_error('annoying_error')
      end
    end
  end

  context 'when App Store returns a forbidden response', :stub_oauth_token do
    let(:event) { create(:event, submission:) }
    let(:submission) { create(:claim) }

    before do
      allow(ENV).to receive(:fetch).and_call_original
      allow(ENV).to receive(:fetch).with('APP_STORE_URL', 'http://localhost:8000')
                                   .and_return('http://appstore.example.com')
      stub_request(:post, "http://appstore.example.com/v1/submissions/#{submission.id}/events").to_return(status: 403)
    end

    context 'when event is already in the app store' do
      before do
        stub_request(:get, "http://appstore.example.com/v1/submissions/#{submission.id}").to_return(
          status: 200,
          body: { events: [event] }.to_json
        )
      end

      it "doesn't raise an error" do
        expect { subject.perform(event:) }.not_to raise_error
      end
    end

    context 'when event is not already in the app store' do
      before do
        stub_request(:get, "http://appstore.example.com/v1/submissions/#{submission.id}").to_return(
          status: 200,
          body: { events: [] }.to_json
        )
      end

      it 'raises an error' do
        expect { subject.perform(event:) }.to raise_error(
          "Cannot sync event #{event.id} to submission #{submission.id} in App Store: Forbidden"
        )
      end
    end

    context 'when it cannot check event status in app store' do
      before do
        stub_request(:get, "http://appstore.example.com/v1/submissions/#{submission.id}").to_return(
          status: 500
        )
      end

      it 'raises an error' do
        expect { subject.perform(event:) }.to raise_error(
          "Unexpected response from AppStore - status 500 for '/v1/submissions/#{submission.id}'"
        )
      end
    end
  end
end
