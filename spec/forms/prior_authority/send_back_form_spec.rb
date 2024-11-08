require 'rails_helper'

RSpec.describe PriorAuthority::SendBackForm, :stub_oauth_token do
  subject { described_class.new(params) }

  let(:submission) { create(:prior_authority_application) }
  let(:further_information_explanation) { 'foo' }
  let(:incorrect_information_explanation) { 'bar' }
  let(:deadline) { DateTime.new(2024, 9, 1, 6, 46, 34) }
  let(:unassignment_stub) do
    stub_request(:delete, "https://appstore.example.com/v1/submissions/#{submission.id}/assignment").to_return(status: 204)
  end

  before do
    unassignment_stub
    allow(WorkingDayService).to receive(:call).with(10).and_return(deadline)
  end

  describe '#comments' do
    context 'when further information is requested' do
      let(:params) do
        {
          updates_needed: ['further_information'],
          further_information_explanation: further_information_explanation
        }
      end

      it { expect(subject.comments).to eq({ further_information: further_information_explanation }) }
    end

    context 'when incorrect information is cited' do
      let(:params) do
        {
          updates_needed: ['incorrect_information'],
          incorrect_information_explanation: incorrect_information_explanation
        }
      end

      it { expect(subject.comments).to eq({ incorrect_information: incorrect_information_explanation }) }
    end

    context 'when both reasons are given' do
      let(:params) do
        {
          updates_needed: %w[further_information incorrect_information],
          further_information_explanation: further_information_explanation,
          incorrect_information_explanation: incorrect_information_explanation
        }
      end

      it 'combines the two explanations' do
        expect(subject.comments).to eq(
          { incorrect_information: incorrect_information_explanation,
            further_information: further_information_explanation }
        )
      end
    end
  end

  describe '#save' do
    let(:fixed_arbitrary_date) { DateTime.new(2023, 12, 3, 12, 3, 12) }
    let(:user) { create(:caseworker) }
    let(:client) { instance_double(AppStoreClient, get_submission: app_store_record, unassign: :success) }
    let(:app_store_record) do
      {
        'version' => 1,
        'json_schema_version' => 1,
        'application_state' => 'submitted',
        'application_type' => 'crm4',
        'application' => submission.data.merge('clean' => true),
        'events' => [],
        'application_id' => submission.id,
      }
    end

    before do
      allow(NotifyAppStore).to receive(:perform_now)
      allow(AppStoreClient).to receive(:new).and_return(client)
      travel_to fixed_arbitrary_date
      create(:assignment, submission:, user:)
    end

    context 'when params are invalid' do
      let(:params) do
        {
          updates_needed: ['further_information'],
          further_information_explanation: '',
          submission: submission
        }
      end

      it 'returns false' do
        expect(subject.save).to be false
      end
    end

    context 'when params are valid for further information' do
      let(:params) do
        {
          updates_needed: ['further_information'],
          further_information_explanation: further_information_explanation,
          submission: submission,
          current_user: user
        }
      end

      it 'returns true' do
        expect(subject.save).to be true
      end

      it 'removes the assignment' do
        expect { subject.save }.to change { submission.assignments.count }.from(1).to(0)
      end

      context 'when save runs' do
        before { subject.save }

        it 'stores information' do
          expect(submission.data['updates_needed']).to include('further_information')
          expect(submission.data['further_information_explanation']).to eq further_information_explanation
          expect(submission.data['further_information'][0]['caseworker_id']).to eq user.id
          expect(submission.data['incorrect_information']).to eq []
        end

        it 'sets a resubmission deadline' do
          expect(DateTime.parse(submission.data['resubmission_deadline'])).to eq deadline
        end

        it 'updates the state' do
          expect(submission.state).to eq 'sent_back'
        end

        it 'adds an event' do
          expect(submission.events.first).to be_a(PriorAuthority::Event::SendBack)
        end

        it 'pulls a clean version of the data from the app store to remove all adjustments' do
          expect(submission.reload.data['clean']).to be true
        end

        it 'notifies the app store' do
          expect(NotifyAppStore).to have_received(:perform_now).with(submission:)
          expect(client).to have_received(:unassign)
        end
      end
    end

    context 'when params are valid for incorrect information' do
      let(:params) do
        {
          updates_needed: ['incorrect_information'],
          incorrect_information_explanation: incorrect_information_explanation,
          submission: submission,
          current_user: user
        }
      end

      it 'returns true' do
        expect(subject.save).to be true
      end

      it 'removes the assignment' do
        expect { subject.save }.to change { submission.assignments.count }.from(1).to(0)
      end

      context 'when save runs' do
        before { subject.save }

        it 'stores information' do
          expect(submission.data['updates_needed']).to include('incorrect_information')
          expect(submission.data['incorrect_information_explanation']).to eq incorrect_information_explanation
          expect(submission.data['incorrect_information'][0]['caseworker_id']).to eq user.id
          expect(submission.data['further_information']).to eq []
        end

        it 'sets a resubmission deadline' do
          expect(DateTime.parse(submission.data['resubmission_deadline'])).to eq deadline
        end

        it 'updates the state' do
          expect(submission.state).to eq 'sent_back'
        end

        it 'adds an event' do
          expect(submission.events.first).to be_a(PriorAuthority::Event::SendBack)
        end

        it 'notifies the app store' do
          expect(NotifyAppStore).to have_received(:perform_now).with(submission:)
        end
      end
    end
  end
end
