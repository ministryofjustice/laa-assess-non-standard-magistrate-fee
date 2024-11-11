require 'rails_helper'

RSpec.describe Event::Note do
  subject { described_class.build(submission:, note:, current_user:) }

  let(:submission) { create(:claim) }
  let(:current_user) { create(:caseworker) }
  let(:note) { 'new note' }
  let(:app_store_client) { instance_double(AppStoreClient, create_events: true) }

  before { allow(AppStoreClient).to receive(:new).and_return(app_store_client) }

  it 'can build a new record' do
    expect(subject).to have_attributes(
      submission_id: submission.id,
      submission_version: 1,
      event_type: 'Event::Note',
      primary_user: current_user,
      details: {
        'comment' => 'new note'
      }
    )
  end

  it 'has a valid title' do
    expect(subject.title).to eq('Caseworker note')
  end

  it 'body is set to comment' do
    expect(subject.body).to eq('new note')
  end
end
