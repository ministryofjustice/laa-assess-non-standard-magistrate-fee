require 'rails_helper'

RSpec.describe Nsm::ClaimNoteForm do
  subject { described_class.new(params) }

  let(:claim) { build(:claim) }

  before do
    allow(AppStoreService).to receive(:get).with(claim.id).and_return(claim)
  end

  describe '#validations' do
    context 'when note is not set' do
      let(:params) { { id: claim.id } }

      it 'is invalid' do
        expect(subject).not_to be_valid
        expect(subject.errors.of_kind?(:note, :blank)).to be(true)
      end
    end
  end

  describe '#persistance' do
    let(:user) { instance_double(User, id: 'user-id') }
    let(:claim) { build(:claim) }
    let(:params) { { id: claim.id, note: 'this is a note', current_user: user } }

    before do
      allow(AppStoreService).to receive(:create_note)
    end

    it { expect(subject.save).to be_truthy }

    it 'creates a Note event' do
      subject.save
      expect(AppStoreService).to have_received(:create_note).with(
        claim, note: 'this is a note', user_id: user.id
      )
    end

    context 'when not valid' do
      let(:params) { { id: claim.id } }

      it { expect(subject.save).to be_falsey }
    end
  end
end
