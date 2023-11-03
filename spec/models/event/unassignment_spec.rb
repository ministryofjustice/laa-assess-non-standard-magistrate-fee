require 'rails_helper'

RSpec.describe Event::Unassignment do
  subject { described_class.build(claim:, user:, current_user:) }

  let(:claim) { create(:claim) }
  let(:user) { create(:caseworker) }

  context 'when user is the same as current user' do
    let(:current_user) { user }

    it 'can build a new record without a secondary user' do
      expect(subject).to have_attributes(
        claim_id: claim.id,
        primary_user_id: user.id,
        claim_version: 1,
        event_type: 'Event::Unassignment',
      )
    end
  end

  context 'when user is the same as current user' do
    let(:current_user) { create(:supervisor) }

    it 'can build a new record without a secondary user' do
      expect(subject).to have_attributes(
        claim_id: claim.id,
        primary_user_id: user.id,
        secondary_user_id: current_user.id,
        claim_version: 1,
        event_type: 'Event::Unassignment',
      )
    end
  end
end
