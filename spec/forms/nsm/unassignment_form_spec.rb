require 'rails_helper'

RSpec.describe Nsm::UnassignmentForm, :stub_oauth_token do
  subject { described_class.new(params) }

  let(:claim) { build(:claim) }
  let(:user) { create :caseworker }
  let(:unassignment_stub) do
    stub_request(:delete, "https://appstore.example.com/v1/submissions/#{claim.id}/assignment").to_return(status: 204)
  end

  before { unassignment_stub }

  describe '#unassignment_user' do
    let(:params) { { claim: claim, current_user: user } }
    let(:claim) { build(:claim, data:) }
    let(:data) { build(:nsm_data, :with_assignment) }

    context 'when assigned user and current_user are the same' do
      before { claim.assigned_user_id = user.id }

      it { expect(subject.unassignment_user).to eq('assigned') }
    end

    context 'when assigned user and current_user are different' do
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
    let(:assigned_user) { create(:caseworker) }
    let(:claim) { build(:claim, data:) }
    let(:data) { build(:nsm_data, assigned_user_id: assigned_user.id) }
    let(:params) { { claim: claim, comment: 'some comment', current_user: user } }

    before do
      allow(Event::Unassignment).to receive(:build)
    end

    it { expect(subject.save).to be_truthy }

    it 'creates a Unassignment event' do
      subject.save
      expect(Event::Unassignment).to have_received(:build).with(
        submission: claim, comment: 'some comment', current_user: user, user: assigned_user
      )
      expect(unassignment_stub).to have_been_requested
    end

    context 'when not valid' do
      let(:params) { {} }

      it { expect(subject.save).to be_falsey }
    end

    context 'if no assigned user' do
      let(:claim) { build(:claim) }

      it 'does not raise any errors' do
        expect(subject.save).to be_truthy
      end

      it 'does not create an Event' do
        subject.save
        expect(Event::Unassignment).not_to have_received(:build)
      end
    end
  end
end
