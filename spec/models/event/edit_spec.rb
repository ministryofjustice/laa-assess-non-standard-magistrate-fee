require 'rails_helper'

RSpec.describe Event::Edit do
  subject { described_class.build(crime_application:, details:, linked:, current_user:) }

  let(:crime_application) { create(:claim) }
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

  it 'can build a new record' do
    expect(subject).to have_attributes(
      crime_application_id: crime_application.id,
      crime_application_version: 1,
      event_type: 'Event::Edit',
      primary_user: current_user,
      linked_type: 'letters',
      linked_id: nil,
      details: details.stringify_keys
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
