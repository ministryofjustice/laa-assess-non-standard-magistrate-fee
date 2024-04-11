require 'rails_helper'

RSpec.describe NotifyAppStore do
  subject { described_class.new }

  let(:submission) { instance_double(Claim) }
  let(:message_builder) { instance_double(described_class::MessageBuilder, message: { some: 'message' }) }

  before do
    allow(described_class::MessageBuilder).to receive(:new)
      .and_return(message_builder)
  end

  describe '#process' do
    context 'when REDIS_HOST is not present' do
      before do
        allow(ENV).to receive(:key?).and_call_original
        allow(ENV).to receive(:key?).with('REDIS_HOST').and_return(false)
        allow(submission).to receive(:namespace).and_return(Nsm)
        allow(Nsm::SubmissionFeedbackMailer).to receive_message_chain(:notify, :deliver_later!)

        expect(AppStoreClient).to receive(:new)
          .and_return(http_notifier)
      end

      let(:http_notifier) { instance_double(AppStoreClient, update_submission: true) }

      it 'does not raise any errors' do
        expect { described_class.process(submission:) }.not_to raise_error
      end

      it 'sends a HTTP message' do
        expect(http_notifier).to receive(:update_submission).with(message_builder.message)

        described_class.process(submission:)
      end

      it 'queues an email' do
        expect(Nsm::SubmissionFeedbackMailer).to receive_message_chain(:notify, :deliver_later!)
        described_class.process(submission:)
      end

      context 'when error during notify process' do
        before do
          allow(http_notifier).to receive(:update_submission).and_raise('annoying_error')
        end

        it 'sends the error to sentry and ignores it' do
          expect(Sentry).to receive(:capture_exception)

          expect { described_class.process(submission:) }.not_to raise_error
        end
      end

      context 'when emails should not be triggered' do
        it 'does not send an email' do
          expect(Nsm::SubmissionFeedbackMailer).not_to receive(:notify)
          described_class.process(submission: submission, trigger_email: false)
        end
      end
    end

    context 'when REDIS_HOST is present' do
      before do
        allow(ENV).to receive(:key?).with('REDIS_HOST').and_return(true)
      end

      it 'schedules the job' do
        expect(described_class).to receive_message_chain(:set, :perform_later).with(submission, trigger_email: true)

        described_class.process(submission:)
      end
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

      subject.perform(submission)
    end

    it 'queues an email' do
      expect(Nsm::SubmissionFeedbackMailer).to receive_message_chain(:notify, :deliver_later!)
      subject.perform(submission)
    end

    context 'when emails should not be triggered' do
      it 'does not send an email' do
        expect(Nsm::SubmissionFeedbackMailer).not_to receive(:notify)
        subject.perform(submission, trigger_email: false)
      end
    end
  end

  describe '#notify' do
    context 'when SNS_URL is not present' do
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

    context 'when SNS_URL is present' do
      before do
        allow(ENV).to receive(:key?).with('SNS_URL').and_return(true)
      end

      it 'raises an error' do
        expect { subject.notify(message_builder) }.to raise_error('SNS notification is not yet enabled')
      end
    end
  end
end
