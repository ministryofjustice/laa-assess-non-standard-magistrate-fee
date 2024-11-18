require 'rails_helper'

RSpec.describe Nsm::Event::SendBack do
  subject { described_class.build(submission:, previous_state:, comment:, current_user:) }

  let(:submission) { build(:claim, state:) }
  let(:state) { 'sent_back' }
  let(:current_user) { create(:caseworker) }
  let(:previous_state) { 'submitted' }
  let(:comment) { 'decison was made' }

  it 'can build a new record' do
    expect(subject).to have_attributes(
      submission_version: 1,
      event_type: 'Nsm::Event::SendBack',
      primary_user_id: current_user.id,
      details: {
        field: 'state',
        from: 'submitted',
        to: 'sent_back',
        comment: 'decison was made'
      }
    )
  end

  it 'has a valid title' do
    expect(subject.title).to eq('Sent back')
  end

  it 'body is set to static text' do
    expect(subject.body).to eq('Sent back to Provider for further information')
  end
end
