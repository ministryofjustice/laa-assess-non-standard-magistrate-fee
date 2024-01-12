require 'rails_helper'

RSpec.describe Event::Unassignment do
  subject { described_class.build(crime_application:, user:, current_user:, comment:) }

  let(:crime_application) { create(:claim) }
  let(:user) { create(:caseworker) }
  let(:comment) { 'test comment' }

  context 'when user is the same as current user' do
    let(:current_user) { user }

    it 'can build a new record without a secondary user' do
      expect(subject).to have_attributes(
        crime_application_id: crime_application.id,
        primary_user_id: user.id,
        crime_application_version: 1,
        event_type: 'Event::Unassignment',
        details: { 'comment' => 'test comment' }
      )
    end

    it 'has a valid title' do
      expect(subject.title).to eq('Caseworker removed self from claim')
    end
  end

  context 'when user is different to the current user' do
    let(:current_user) { create(:supervisor) }

    it 'can build a new record with a secondary user' do
      expect(subject).to have_attributes(
        crime_application_id: crime_application.id,
        primary_user_id: user.id,
        secondary_user_id: current_user.id,
        crime_application_version: 1,
        event_type: 'Event::Unassignment',
        details: { 'comment' => 'test comment' }
      )
    end

    it 'has a valid title' do
      expect(subject.title).to eq('Caseworker removed from claim by super visor')
    end
  end
end
