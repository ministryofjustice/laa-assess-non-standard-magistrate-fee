require 'rails_helper'

RSpec.describe Nsm::SendBackForm do
  subject { described_class.new(params) }

  let(:claim) { create(:claim) }

  describe '#validations' do
    let(:params) { { claim:, comment: } }

    context 'when comment is set' do
      let(:comment) { 'some comment' }

      it { expect(subject).to be_valid }
    end

    context 'when comment is blank' do
      let(:comment) { nil }

      it 'is invalid' do
        expect(subject).not_to be_valid
        expect(subject.errors.of_kind?(:comment, :blank)).to be(true)
      end
    end
  end

  describe '#persistance' do
    let(:user) { instance_double(User) }
    let(:claim) { create(:claim, assignments: [build(:assignment)]) }
    let(:params) { { claim: claim, comment: 'some comment', current_user: user } }

    before do
      allow(Nsm::Event::SendBack).to receive(:build)
      allow(NotifyAppStore).to receive(:perform_later)
    end

    it { expect(subject.save).to be_truthy }

    it 'updates the claim' do
      subject.save
      expect(claim.reload).to have_attributes(state: 'sent_back')
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

    it 'trigger an update to the app store' do
      subject.save
      expect(NotifyAppStore).to have_received(:perform_later).with(submission: claim)
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
