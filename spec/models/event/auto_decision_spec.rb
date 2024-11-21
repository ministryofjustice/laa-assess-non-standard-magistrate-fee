require 'rails_helper'

RSpec.describe Event::AutoDecision do
  subject { described_class.build(submission:, previous_state:) }

  let(:submission) { build(:prior_authority_application, state:) }
  let(:state) { PriorAuthorityApplication::AUTO_GRANT }
  let(:previous_state) { 'submitted' }

  it 'can build a new record' do
    expect(subject).to have_attributes(
      submission_version: 1,
      event_type: 'Event::AutoDecision',
      details: {
        field: 'state',
        from: 'submitted',
        to: 'auto_grant'
      }
    )
  end

  it 'has a valid title' do
    expect(subject.title).to eq('Automatic decision made to grant claim')
  end
end
