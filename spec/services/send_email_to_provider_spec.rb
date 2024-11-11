require 'rails_helper'

RSpec.describe SendEmailToProvider do
  describe '#perform_later' do
    subject { described_class.perform_later(submission) }

    let(:submission) { create :claim, send_email_to_provider_completed: nil }

    it 'sets the flag' do
      subject
      expect(submission.reload.send_email_to_provider_completed).to be false
    end
  end

  describe '#perform' do
    subject { described_class.new.perform(submission.id) }

    let(:dummy) { double(:mailer, deliver_now!: true) }

    before do
      allow(Submission).to receive(:load_from_app_store).and_return(submission)
    end

    context 'with an NSM claim' do
      let(:submission) { create :claim, send_email_to_provider_completed: false }

      before do
        allow(Nsm::EmailToProviderMailer).to receive(:notify).and_return(dummy)
      end

      it 'delivers an email' do
        subject
        expect(Nsm::EmailToProviderMailer).to have_received(:notify) do |arg|
          expect(arg.id).to eq submission.id
        end
        expect(dummy).to have_received(:deliver_now!)
      end

      it 'updates the flag' do
        subject
        expect(submission.reload).to be_send_email_to_provider_completed
      end
    end

    context 'with a PA application' do
      let(:submission) { create :prior_authority_application, send_email_to_provider_completed: false }

      before do
        allow(PriorAuthority::EmailToProviderMailer).to receive(:notify).and_return(dummy)
      end

      it 'delivers an email' do
        subject
        expect(PriorAuthority::EmailToProviderMailer).to have_received(:notify) do |arg|
          expect(arg.id).to eq submission.id
        end
        expect(dummy).to have_received(:deliver_now!)
      end

      it 'updates the flag' do
        subject
        expect(submission.reload).to be_send_email_to_provider_completed
      end
    end
  end
end
