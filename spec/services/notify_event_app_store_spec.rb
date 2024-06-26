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
end
