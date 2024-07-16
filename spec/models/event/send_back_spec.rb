require 'rails_helper'

RSpec.describe Nsm::Event::SendBack do
  subject { described_class.build(submission:, previous_state:, comment:, current_user:) }

  let(:submission) { create(:claim, state:) }
  let(:state) { 'further_info' }
  let(:current_user) { create(:caseworker) }
  let(:previous_state) { 'submitted' }
  let(:comment) { 'decison was made' }

  it 'can build a new record' do
    expect(subject).to have_attributes(
      submission_id: submission.id,
      submission_version: 1,
      event_type: 'Nsm::Event::SendBack',
      primary_user: current_user,
      details: {
        'field' => 'state',
        'from' => 'submitted',
        'to' => 'further_info',
        'comment' => 'decison was made'
      }
    )
  end

  it 'has a valid title' do
    expect(subject.title).to eq('Claim sent back to provider')
  end

  it 'body is set to comment' do
    expect(subject.body).to eq('decison was made')
  end
end
