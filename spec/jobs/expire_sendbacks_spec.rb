require 'rails_helper'

RSpec.describe ExpireSendbacks do
  describe '#perform' do
    context 'when the submission is a prior authority application' do
      let(:application) do
        create(:prior_authority_application,
               state: state,
               data: build(:prior_authority_data, resubmission_deadline: deadline))
      end

      before do
        application
        allow(NotifyAppStore).to receive(:perform_now)
        described_class.new.perform
      end

      context 'when an application is overdue expiry' do
        let(:state) { 'sent_back' }
        let(:deadline) { 1.day.ago }

        it 'marks as expired' do
          expect(application.reload).to be_expired
        end

        it 'creates an event' do
          expect(application.events.first).to be_a(Event::Expiry)
        end

        it 'updates the app store without an email' do
          expect(NotifyAppStore).to have_received(:perform_now).with(submission: application, trigger_email: false)
        end
      end

      context 'when an application is not sent back' do
        let(:state) { 'submitted' }
        let(:deadline) { 1.day.ago }

        it 'does not mark as expired' do
          expect(application.reload).not_to be_expired
        end
      end

      context 'when an application is only recently sent back' do
        let(:state) { 'sent_back' }
        let(:deadline) { 1.day.from_now }

        it 'does not mark as expired' do
          expect(application.reload).not_to be_expired
        end
      end
    end
  end

  context 'when the submission is a claim' do
    let(:claim) { create(:claim, state:, data:) }

    before do
      claim
      allow(NotifyAppStore).to receive(:perform_now)
      described_class.new.perform
    end

    context 'when a claim is overdue expiry' do
      let(:state) { 'sent_back' }
      let(:data) { { 'resubmission_deadline' => 1.hour.ago.to_datetime } }

      it 'marks as expired' do
        expect(claim.reload).to be_expired
      end

      it 'creates an event' do
        expect(claim.events.first).to be_a(Event::Expiry)
      end

      it 'updates the app store without an email' do
        expect(NotifyAppStore).to have_received(:perform_now).with(submission: claim, trigger_email: false)
      end
    end

    context 'when a claim is not sent back' do
      let(:state) { 'provider_updated' }
      let(:data) { { 'resubmission_deadline' => 1.hour.ago.to_datetime } }

      it 'does not mark as expired' do
        expect(claim.reload).not_to be_expired
      end
    end

    context 'when a claim is not ready to be expired' do
      let(:state) { 'sent_back' }
      let(:data) { { 'resubmission_deadline' => 2.hours.from_now.to_datetime } }

      it 'does not mark as expired' do
        expect(claim.reload).not_to be_expired
      end
    end

    context 'when a claim does not have a resubmission deadline' do
      let(:state) { 'sent_back' }
      let(:data) { {} }

      it 'does not mark as expired' do
        expect(claim.reload).not_to be_expired
      end
    end
  end
end
