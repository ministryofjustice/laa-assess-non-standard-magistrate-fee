require 'rails_helper'

RSpec.describe SendEmailToProvider do
  describe '#perform_later' do
    subject { described_class.perform_later(submission) }

    let(:submission) { build :claim }

    it 'runs without error' do
      expect { subject }.not_to raise_error
    end
  end

  describe '#perform' do
    subject { described_class.new.perform(submission.id) }

    let(:dummy) { double(:mailer, deliver_now!: true) }

    before do
      allow(Submission).to receive(:load_from_app_store).and_return(submission)
    end

    context 'with an NSM claim' do
      let(:submission) { build :claim }

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
    end

    context 'with a PA application' do
      let(:submission) { build :prior_authority_application }

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
    end
  end
end
