require 'rails_helper'

RSpec.describe PriorAuthority::SendBackForm do
  subject { described_class.new(params) }

  let(:submission) { create(:prior_authority_application) }
  let(:further_information_explanation) { 'foo' }
  let(:incorrect_information_explanation) { 'bar' }

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

    before do
      allow(NotifyAppStore).to receive(:perform_later)
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
        end

        it 'sets a resubmission deadline' do
          expect(DateTime.parse(submission.data['resubmission_deadline'])).to eq 14.days.from_now
        end

        it 'updates the state' do
          expect(submission.state).to eq 'sent_back'
        end

        it 'adds an event' do
          expect(submission.events.first).to be_a(PriorAuthority::Event::SendBack)
        end

        it 'notifies the app store' do
          expect(NotifyAppStore).to have_received(:perform_later).with(submission:)
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
          expect(submission.data['further_information']).to be_nil
        end

        it 'sets a resubmission deadline' do
          expect(DateTime.parse(submission.data['resubmission_deadline'])).to eq 14.days.from_now
        end

        it 'updates the state' do
          expect(submission.state).to eq 'sent_back'
        end

        it 'adds an event' do
          expect(submission.events.first).to be_a(PriorAuthority::Event::SendBack)
        end

        it 'notifies the app store' do
          expect(NotifyAppStore).to have_received(:perform_later).with(submission:)
        end
      end
    end
  end
end
