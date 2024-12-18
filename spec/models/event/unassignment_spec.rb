require 'rails_helper'

RSpec.describe Event::Unassignment do
  subject { described_class.build(submission:, user:, current_user:, comment:) }

  let(:submission) { build(:claim) }
  let(:user) { create(:caseworker) }
  let(:comment) { 'test comment' }

  before do
    allow(NotifyEventAppStore).to receive(:perform_now)
  end

  context 'when user is the same as current user' do
    let(:current_user) { user }

    it 'can build a new record without a secondary user' do
      expect(subject).to have_attributes(
        primary_user_id: user.id,
        submission_version: 1,
        event_type: 'Event::Unassignment',
        details: { comment: 'test comment' }
      )
    end

    it 'notifies the app store' do
      event = Event.send(:new)
      expect(described_class).to receive(:construct).and_return(event)

      subject

      expect(NotifyEventAppStore).to have_received(:perform_now).with(event:, submission:)
    end

    it 'has a valid title' do
      expect(subject.title).to eq('Caseworker removed self from claim')
    end
  end

  context 'when user is different to the current user' do
    let(:current_user) { create(:supervisor) }

    it 'can build a new record with a secondary user' do
      expect(subject).to have_attributes(
        primary_user_id: user.id,
        secondary_user_id: current_user.id,
        submission_version: 1,
        event_type: 'Event::Unassignment',
        details: { comment: 'test comment' }
      )
    end

    it 'notifies the app store' do
      event = Event.send(:new)
      expect(described_class).to receive(:construct).and_return(event)
      expect(NotifyEventAppStore).to receive(:perform_now).with(event:, submission:)

      subject
    end

    it 'has a valid title' do
      expect(subject.title).to eq('Caseworker removed from claim by super visor')
    end
  end

  context 'when user not persisted locally' do
    let(:current_user) { build(:supervisor, id: SecureRandom.uuid) }

    it 'at least does not explode' do
      expect(subject.title).to eq('Caseworker removed from claim by Unknown caseworker')
    end
  end
end
