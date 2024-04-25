require 'rails_helper'

RSpec.describe ExpireSendbacks do
  describe '#perform' do
    let(:application) { create(:prior_authority_application, state:, updated_at:) }

    before do
      application
      allow(NotifyAppStore).to receive(:perform_later)
      described_class.new.perform
    end

    context 'when an application is overdue expiry' do
      let(:state) { 'sent_back' }
      let(:updated_at) { 15.days.ago }

      it 'marks as expired' do
        expect(application.reload).to be_expired
      end

      it 'creates an event' do
        expect(application.events.first).to be_a(Event::Expiry)
      end

      it 'updates the app store without an email' do
        expect(NotifyAppStore).to have_received(:perform_later).with(submission: application, trigger_email: false)
      end
    end

    context 'when an application is not sent back' do
      let(:state) { 'submitted' }
      let(:updated_at) { 15.days.ago }

      it 'does not mark as expired' do
        expect(application.reload).not_to be_expired
      end
    end

    context 'when an application is only recently sent back' do
      let(:state) { 'sent_back' }
      let(:updated_at) { 10.days.ago }

      it 'does not mark as expired' do
        expect(application.reload).not_to be_expired
      end
    end
  end
end
