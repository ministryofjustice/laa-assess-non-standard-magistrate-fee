require 'rails_helper'

RSpec.describe Nsm::UnassignmentForm do
  subject { described_class.new(params) }

  let(:claim) { build(:claim) }

  describe '#unassignment_user' do
    let(:params) { { claim: claim, current_user: user } }
    let(:claim) { build(:claim, assigned_user: build(:caseworker)) }

    context 'when assigned user and current_user are the same' do
      let(:user) { claim.assigned_user }

      it { expect(subject.unassignment_user).to eq('assigned') }
    end

    context 'when assigned user and current_user are different' do
      let(:user) { instance_double(User) }

      it { expect(subject.unassignment_user).to eq('other') }
    end
  end

  describe '#validations' do
    context 'when comment is blank' do
      let(:params) { { claim: claim, comment: nil } }

      it 'is invalid' do
        expect(subject).not_to be_valid
        expect(subject.errors.of_kind?(:comment, :blank)).to be(true)
      end
    end

    context 'when comment is set' do
      let(:params) { { claim: claim, comment: 'part grant comment' } }

      it { expect(subject).to be_valid }
    end
  end

  describe '#persistance' do
    let(:user) { instance_double(User) }
    let(:claim) { build(:claim, assigned_user: build(:caseworker)) }
    let(:params) { { claim: claim, comment: 'some comment', current_user: user } }

    before do
      allow(AppStoreService).to receive(:unassign)
    end

    it { expect(subject.save).to be_truthy }

    it 'requests unassignment' do
      subject.save
      expect(AppStoreService).to have_received(:unassign).with(claim, 'some comment', user)
    end

    context 'when not valid' do
      let(:params) { {} }

      it { expect(subject.save).to be_falsey }
    end
  end
end
