require 'rails_helper'

RSpec.describe Event::Edit do
  subject { described_class.build(submission:, details:, linked:, current_user:) }

  let(:submission) { build(:claim) }
  let(:current_user) { create(:caseworker) }
  let(:details) do
    {
      field: 'uplift',
      from: 95,
      to: 0,
      change: 0,
      comment: 'removed'
    }
  end
  let(:linked) { { type: 'letters' } }
  let(:app_store_client) { instance_double(AppStoreClient, create_events: true) }

  before { allow(AppStoreClient).to receive(:new).and_return(app_store_client) }

  it 'can build a new record' do
    expect(subject).to have_attributes(
      submission_version: 1,
      event_type: 'Event::Edit',
      primary_user_id: current_user.id,
      linked_type: 'letters',
      linked_id: nil,
      details: details
    )
  end

  context 'when linked id is set' do
    let(:linked) { { type: 'work_items', id: SecureRandom.uuid } }

    it 'sets the linked record fields' do
      expect(subject).to have_attributes(
        linked_type: 'work_items',
        linked_id: linked[:id],
      )
    end
  end
end
