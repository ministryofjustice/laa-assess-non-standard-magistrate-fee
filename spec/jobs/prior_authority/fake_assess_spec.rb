require 'rails_helper'

RSpec.describe PriorAuthority::FakeAssess do
  subject { described_class.new }

  let(:application) { create(:prior_authority_application, state: :submitted) }

  context 'when harnessing the power of randomness' do
    before do
      create(:caseworker)
      allow(NotifyAppStore).to receive(:perform_later)
      allow(SecureRandom).to receive(:rand).and_return random_choice
      subject.perform([application.id])
    end

    context 'when granting applications' do
      let(:random_choice) { 0 }

      context 'when application is not assessable' do
        let(:application) { create(:prior_authority_application, state: :rejected) }

        it 'does not change the application' do
          expect(application.reload).to be_rejected
        end
      end

      it 'marks as granted' do
        expect(application.reload).to be_granted
      end

      it 'notifies the app store' do
        expect(NotifyAppStore).to have_received(:perform_later).with(submission: application)
      end
    end

    context 'when part-granting applications' do
      let(:random_choice) { 1 }

      it 'marks as part-granted' do
        expect(application.reload).to be_part_grant
      end

      it 'notifies the app store' do
        expect(NotifyAppStore).to have_received(:perform_later).with(submission: application)
      end
    end

    context 'when rejecting applications' do
      let(:random_choice) { 2 }

      it 'marks as rejected' do
        expect(application.reload).to be_rejected
      end

      it 'notifies the app store' do
        expect(NotifyAppStore).to have_received(:perform_later).with(submission: application)
      end
    end

    context 'when sending back applications for further info' do
      let(:random_choice) { 3 }

      it 'marks as sent back' do
        expect(application.reload).to be_sent_back
      end

      it 'adds a further information object' do
        expect(application.reload.data['further_information'][0]).to be_present
      end

      it 'notifies the app store' do
        expect(NotifyAppStore).to have_received(:perform_later).with(submission: application)
      end
    end

    context 'when sending back applications for corrections' do
      let(:random_choice) { 4 }

      it 'marks as sent back' do
        expect(application.reload).to be_sent_back
      end

      it 'specifies corrections needed' do
        expect(application.reload.events.last['details']['updates_needed']).to include('incorrect_information')
      end

      it 'notifies the app store' do
        expect(NotifyAppStore).to have_received(:perform_later).with(submission: application)
      end
    end
  end

  context 'when randomness goes wrong' do
    before { allow(SecureRandom).to receive(:rand).and_return 5 }

    it 'raises an error' do
      expect { subject.perform([application.id]) }.to raise_error StandardError
    end
  end
end
