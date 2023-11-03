require 'rails_helper'

RSpec.describe Claim do
  let(:claim) { create(:claim) }

  describe '#unassigned_claims' do
    let(:user) { create(:caseworker) }

    it 'returns claims oldest to youngest' do
      claim1 = create(:claim)
      claim2 = create(:claim)
      claim3 = create(:claim)

      expect(described_class.unassigned_claims(user)).to eq([claim1, claim2, claim3])
    end

    it 'does not include claims which have already been assigned' do
      claim.assignments.create(user: create(:caseworker))

      expect(described_class.unassigned_claims(user)).to eq([])
    end

    it 'does not include claims the user has been unassigned from' do
      Event::Unassignment.build(claim:, user:, current_user: user)

      expect(described_class.unassigned_claims(user)).to eq([])
    end
  end

  describe 'claim assignment' do
    let(:user) { create(:caseworker) }

    it 'does not allow a claim to have multiple live assignments' do
      claim.assignments.create!(user: user)
      assignment = claim.assignments.new(user: user)

      expect(assignment).not_to be_valid
      expect(assignment.errors.of_kind?(:claim, :taken)).to be(true)
    end
  end
end