require 'rails_helper'

RSpec.describe Nsm::SendBackForm do
  subject { described_class.new(params) }

  let(:claim) { create(:claim) }

  describe '#validations' do
    let(:params) { { claim:, send_back_comment: } }

    context 'when comment is set' do
      let(:send_back_comment) { 'some comment' }

      it { expect(subject).to be_valid }
    end

    context 'when comment is blank' do
      let(:send_back_comment) { nil }

      it 'is invalid' do
        expect(subject).not_to be_valid
        expect(subject.errors.of_kind?(:send_back_comment, :blank)).to be(true)
      end
    end
  end

  describe '#persistance', :calls_app_store do
    let(:user) { instance_double(User, id: SecureRandom.uuid) }
    let(:claim) { create(:claim, assignments: [build(:assignment)]) }
    let(:params) { { claim: claim, send_back_comment: 'some comment', current_user: user } }
    let(:unassignment_stub) do
      stub_request(:delete, "https://appstore.example.com/v1/submissions/#{claim.id}/assignment").to_return(status: 204)
    end

    before do
      allow(Nsm::Event::SendBack).to receive(:build)
      allow(NotifyAppStore).to receive(:perform_later)
      unassignment_stub
    end

    it { expect(subject.save).to be_truthy }

    it 'updates the state' do
      subject.save
      expect(claim.reload).to have_attributes(state: 'sent_back')
    end

    it 'adds the comment' do
      subject.save
      expect(claim.reload.data).to include('assessment_comment' => 'some comment')
    end

    it 'removes the assignment' do
      expect { subject.save }.to change { claim.assignments.count }.from(1).to(0)
    end

    it 'creates a Decision event' do
      subject.save
      expect(Nsm::Event::SendBack).to have_received(:build).with(
        submission: claim, comment: 'some comment', previous_state: 'submitted', current_user: user
      )
    end

    context 'rfi enabled' do
      before do
        allow(FeatureFlags).to receive(:nsm_rfi_loop).and_return(
          instance_double(FeatureFlags::EnabledFeature, enabled?: true)
        )
        allow(WorkingDayService).to receive(:call).and_return 10.days.from_now
      end

      it 'adds a further_information array element to claim data' do
        subject.save
        expect(claim.reload.data['further_information']).to be_a(Array)
      end
    end

    it 'trigger an update to the app store' do
      subject.save
      expect(NotifyAppStore).to have_received(:perform_later).with(submission: claim)
      expect(unassignment_stub).to have_been_requested
    end

    context 'when not valid' do
      let(:params) { {} }

      it { expect(subject.save).to be_falsey }
    end

    context 'when error during save' do
      before do
        allow(Claim).to receive(:find_by).and_return(claim)
        allow(claim).to receive(:update!).and_raise('not found')
      end

      it { expect { subject.save }.to raise_error('not found') }
    end
  end
end
