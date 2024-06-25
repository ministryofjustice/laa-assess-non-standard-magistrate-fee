require 'rails_helper'

RSpec.describe Event::Unassignment do
  subject { described_class.build(submission:, user:, current_user:, comment:) }

  let(:submission) { create(:claim) }
  let(:user) { create(:caseworker) }
  let(:comment) { 'test comment' }

  context 'when user is the same as current user' do
    let(:current_user) { user }

    it 'can build a new record without a secondary user' do
      expect(subject).to have_attributes(
        submission_id: submission.id,
        primary_user_id: user.id,
        submission_version: 1,
        event_type: 'Event::Unassignment',
        details: { 'comment' => 'test comment' }
      )
    end

    it 'notifies the app store' do
      event = instance_double(Event)
      expect(described_class).to receive(:create).and_return(event)
      expect(NotifyEventAppStore).to receive(:perform_later).with(event:)

      subject
    end

    it 'has a valid title' do
      expect(subject.title).to eq('Caseworker removed self from claim')
    end
  end

  context 'when user is different to the current user' do
    let(:current_user) { create(:supervisor) }

    it 'can build a new record with a secondary user' do
      expect(subject).to have_attributes(
        submission_id: submission.id,
        primary_user_id: user.id,
        secondary_user_id: current_user.id,
        submission_version: 1,
        event_type: 'Event::Unassignment',
        details: { 'comment' => 'test comment' }
      )
    end

    it 'notifies the app store' do
      event = instance_double(Event)
      expect(described_class).to receive(:create).and_return(event)
      expect(NotifyEventAppStore).to receive(:perform_later).with(event:)

      subject
    end

    it 'has a valid title' do
      expect(subject.title).to eq('Caseworker removed from claim by super visor')
    end
  end
end
