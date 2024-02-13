require 'rails_helper'

RSpec.describe Nsm::SendBackForm do
  subject { described_class.new(params) }

  let(:claim) { build(:claim) }

  describe '#validations' do
    context 'when state is not set' do
      let(:params) { {} }

      it 'is invalid' do
        expect(subject).not_to be_valid
        expect(subject.errors.of_kind?(:state, :inclusion)).to be(true)
      end
    end

    context 'when state is invalid' do
      let(:params) { { claim: claim, state: 'other' } }

      it 'is invalid' do
        expect(subject).not_to be_valid
        expect(subject.errors.of_kind?(:state, :inclusion)).to be(true)
      end
    end

    context 'when state is further_info' do
      let(:params) { { claim: claim, state: 'further_info', comment: comment } }
      let(:comment) { 'some comment' }

      it { expect(subject).to be_valid }

      context 'when comment is blank' do
        let(:comment) { nil }

        it 'is invalid' do
          expect(subject).not_to be_valid
          expect(subject.errors.of_kind?(:comment, :blank)).to be(true)
        end
      end
    end

    context 'when state is provider_requested' do
      context 'when comment is blank' do
        let(:params) { { claim: claim, state: 'provider_requested', comment: nil } }

        it 'is invalid' do
          expect(subject).not_to be_valid
          expect(subject.errors.of_kind?(:comment, :blank)).to be(true)
        end
      end

      context 'when comment is set' do
        let(:params) { { claim: claim, state: 'provider_requested', comment: 'part grant comment' } }

        it { expect(subject).to be_valid }
      end
    end
  end

  describe '#persistance' do
    let(:user) { instance_double(User, id: 'user-id') }
    let(:claim) { build(:claim) }
    let(:params) { { claim: claim, state: 'further_info', comment: 'some comment', current_user: user } }

    before do
      allow(MakeDecisionService).to receive(:process)
    end

    it { expect(subject.save).to be_truthy }

    it 'trigger an update to the app store' do
      subject.save
      expect(MakeDecisionService).to have_received(:process).with(
        submission: claim,
        comment: 'some comment',
        user_id: user.id,
        application_state: 'further_info'
      )
    end

    context 'when not valid' do
      let(:params) { {} }

      it { expect(subject.save).to be_falsey }
    end
  end
end
