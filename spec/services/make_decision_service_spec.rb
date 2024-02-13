require 'rails_helper'

RSpec.describe MakeDecisionService do
  subject { described_class.new }

  let(:submission) { instance_double(Claim, id: '123') }
  let(:comment) { 'foo' }
  let(:user_id) { '123' }
  let(:application_state) { 'granted' }

  describe '#process' do
    context 'when REDIS_HOST is not present' do
      before do
        allow(ENV).to receive(:key?).and_call_original
        allow(ENV).to receive(:key?).with('REDIS_HOST').and_return(false)
        allow(SubmissionFeedbackMailer).to receive_message_chain(:notify, :deliver_later!)
        allow(AppStoreService).to receive(:change_state)
      end

      it 'does not raise any errors' do
        expect { described_class.process(submission:, comment:, user_id:, application_state:) }.not_to raise_error
      end

      it 'sends a HTTP message' do
        expect(AppStoreService).to receive(:change_state)

        described_class.process(submission:, comment:, user_id:, application_state:)
      end

      describe 'when error during notify process' do
        before do
          allow(AppStoreService).to receive(:change_state).and_raise('annoying_error')
        end

        it 'sends the error to sentry and ignores it' do
          expect(Sentry).to receive(:capture_exception)

          expect { described_class.process(submission:, comment:, user_id:, application_state:) }.not_to raise_error
        end
      end
    end

    context 'when REDIS_HOST is present' do
      before do
        allow(ENV).to receive(:key?).with('REDIS_HOST').and_return(true)
      end

      it 'schedules the job' do
        expect(described_class).to receive_message_chain(:set, :perform_later).with(submission, comment, user_id,
                                                                                    application_state)

        described_class.process(submission:, comment:, user_id:, application_state:)
      end
    end
  end

  describe '#perform' do
    before do
      allow(SubmissionFeedbackMailer).to receive_message_chain(:notify, :deliver_later!)
    end

    it 'sends an HTTP message' do
      expect(AppStoreService).to receive(:change_state)

      described_class.new.perform(submission, comment, user_id, application_state)
    end
  end
end
