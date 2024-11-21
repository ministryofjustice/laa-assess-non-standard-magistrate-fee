require 'rails_helper'

RSpec.describe Event::NewVersion do
  subject { described_class.build(submission:) }

  before do
    allow(NotifyEventAppStore).to receive(:perform_now)
  end

  let(:submission) { build(:claim) }

  it 'can build a new record' do
    expect(subject).to have_attributes(
      submission_version: 1,
      event_type: 'Event::NewVersion',
    )
  end

  it 'has a valid title' do
    expect(subject.title).to eq('Received')
  end
end
