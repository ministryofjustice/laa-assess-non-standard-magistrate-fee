require 'rails_helper'

RSpec.describe Event::NewVersion do
  subject { described_class.build(submission:) }

  let(:submission) { create(:claim) }

  it 'can build a new record' do
    expect(subject).to have_attributes(
      submission_id: submission.id,
      submission_version: 1,
      event_type: 'Event::NewVersion',
    )
  end

  it 'has a valid title' do
    expect(subject.title).to eq('New claim received')
  end
end
