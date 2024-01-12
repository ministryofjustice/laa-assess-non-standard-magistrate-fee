require 'rails_helper'

RSpec.describe Event::Assignment do
  subject { described_class.build(crime_application: claim, current_user: current_user) }

  let(:claim) { create(:claim) }
  let(:current_user) { create(:caseworker) }

  it 'can build a new record' do
    expect(subject).to have_attributes(
      crime_application_id: claim.id,
      primary_user_id: current_user.id,
      crime_application_version: 1,
      event_type: 'Event::Assignment',
    )
  end

  it 'has a valid title' do
    expect(subject.title).to eq('Claim allocated to caseworker')
  end
end
