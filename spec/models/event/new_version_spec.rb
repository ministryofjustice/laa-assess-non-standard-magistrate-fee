require 'rails_helper'

RSpec.describe Event::NewVersion do
  subject { described_class.build(crime_application:) }

  let(:crime_application) { create(:claim) }

  it 'can build a new record' do
    expect(subject).to have_attributes(
      crime_application_id: crime_application.id,
      crime_application_version: 1,
      event_type: 'Event::NewVersion',
    )
  end

  it 'has a valid title' do
    expect(subject.title).to eq('New claim received')
  end
end
