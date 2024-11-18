require 'rails_helper'

RSpec.describe Event::ChangeRisk do
  subject { described_class.build(submission:, explanation:, previous_risk_level:, current_user:) }

  let(:submission) { build(:claim, risk:) }
  let(:risk) { 'low' }
  let(:current_user) { create(:caseworker) }
  let(:previous_risk_level) { 'high' }
  let(:explanation) { 'risk has been changed' }
  let(:app_store_client) { instance_double(AppStoreClient, create_events: true) }

  before { allow(AppStoreClient).to receive(:new).and_return(app_store_client) }

  it 'can build a new record' do
    expect(subject).to have_attributes(
      submission_version: 1,
      event_type: 'Event::ChangeRisk',
      primary_user_id: current_user.id,
      details: {
        field: 'risk',
        from: previous_risk_level,
        to: risk,
        comment: explanation
      }
    )
  end

  it 'has a valid title' do
    expect(subject.title).to eq('Claim risk changed to low risk')
  end
end
