require 'rails_helper'

RSpec.describe PriorAuthority::FakeAssess, :calls_app_store do
  subject { described_class.new }

  let(:application) { create(:prior_authority_application, state: :submitted) }
  let(:unassignment_stub) do
    stub_request(:delete, "https://appstore.example.com/v1/submissions/#{application.id}/assignment").to_return(status: 204)
  end

  before { unassignment_stub }

  context 'when harnessing the power of randomness' do
    let(:client) { instance_double(AppStoreClient, get_submission: app_store_record, unassign: :success) }
    let(:app_store_record) { { 'application' => application.data } }

    before do
      create(:caseworker)
      allow(NotifyAppStore).to receive(:perform_later)
      allow(AppStoreClient).to receive(:new).and_return(client)
      allow(SecureRandom).to receive(:rand).and_return random_choice
      allow(WorkingDayService).to receive(:call).and_return 3.days.from_now
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
        expect(client).to have_received(:unassign)
      end
    end

    context 'when sending back applications for corrections' do
      let(:random_choice) { 4 }

      it 'marks as sent back' do
        expect(application.reload).to be_sent_back
      end

      it 'specifies corrections needed' do
        send_back_event = application.reload.events.find_by(event_type: 'PriorAuthority::Event::SendBack')
        expect(send_back_event['details']['updates_needed']).to include('incorrect_information')
      end

      it 'notifies the app store' do
        expect(NotifyAppStore).to have_received(:perform_later).with(submission: application)
        expect(client).to have_received(:unassign)
      end
    end

    context 'when leaving as-is' do
      let(:random_choice) { 5 }

      it 'does not modify application' do
        expect(application.reload).to be_submitted
      end
    end
  end
end
