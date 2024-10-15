require 'rails_helper'

RSpec.describe NotifyAppStore do
  subject { described_class.new }

  let(:submission) { instance_double(Claim, update!: true) }
  let(:message_builder) { instance_double(described_class::MessageBuilder, message: { some: 'message' }) }

  before do
    allow(described_class::MessageBuilder).to receive(:new)
      .and_return(message_builder)

    allow(submission).to receive(:with_lock).and_yield
  end

  describe '.perform_later' do
    let(:claim) { create :claim, notify_app_store_completed: nil }

    it 'sets a flag' do
      described_class.perform_later(submission: claim)
      expect(claim.reload.notify_app_store_completed).to be false
    end
  end

  describe '#perform' do
    let(:http_notifier) { instance_double(AppStoreClient, update_submission: true) }

    before do
      allow(AppStoreClient).to receive(:new).and_return(http_notifier)
      allow(submission).to receive(:namespace).and_return(Nsm)
      allow(Nsm::SubmissionFeedbackMailer).to receive_message_chain(:notify, :deliver_later!)
    end

    it 'creates a new MessageBuilder' do
      expect(described_class::MessageBuilder).to receive(:new)
        .with(submission:)

      subject.perform(submission:)
    end

    it 'does not queue an email' do
      expect(Nsm::SubmissionFeedbackMailer).not_to receive(:notify)
      subject.perform(submission:)
    end

    context 'when email flag is set' do
      before do
        allow(ENV).to receive(:fetch).with('SEND_EMAILS', 'false').and_return 'true'
      end

      it 'queues an email' do
        expect(Nsm::SubmissionFeedbackMailer).to receive_message_chain(:notify, :deliver_later!)
        subject.perform(submission:)
      end
    end

    it 'updates the record' do
      expect(submission).to receive(:update!).with(notify_app_store_completed: true)
      subject.perform(submission:)
    end

    context 'when emails should not be triggered' do
      it 'does not send an email' do
        expect(Nsm::SubmissionFeedbackMailer).not_to receive(:notify)
        subject.perform(submission: submission, trigger_email: false)
      end
    end
  end

  describe '#notify' do
    let(:http_notifier) { instance_double(AppStoreClient, update_submission: true) }

    before do
      allow(AppStoreClient).to receive(:new)
        .and_return(http_notifier)
    end

    it 'creates a new AppStoreClient instance' do
      expect(AppStoreClient).to receive(:new)

      subject.notify(message_builder)
    end

    it 'sends a HTTP message' do
      expect(http_notifier).to receive(:update_submission).with(message_builder.message)

      subject.notify(message_builder)
    end

    describe 'when error during notify process' do
      before do
        allow(http_notifier).to receive(:update_submission).and_raise('annoying_error')
      end

      it 'allows the error to be raised - should reset the sidekiq job' do
        expect { subject.notify(message_builder) }.to raise_error('annoying_error')
      end
    end
  end
end
