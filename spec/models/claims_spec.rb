require 'rails_helper'

RSpec.describe Claim do
  let(:claim) { create(:claim) }

  describe '#auto_assignable' do
    let(:user) { create(:caseworker) }

    it 'assigns the claim to the user' do
      expect(described_class.auto_assignable(user)).to eq([claim])
    end

    it 'does not include claims which have already been assigned' do
      claim.assignments.create(user: create(:caseworker))

      expect(described_class.auto_assignable(user)).to eq([])
    end

    it 'does not include claims the user has been unassigned from' do
      Event::Unassignment.build(submission: claim, user: user, current_user: user, comment: 'test')

      expect(described_class.auto_assignable(user)).to eq([])
    end

    it 'does not include high risk claims' do
      claim.update!(risk: 'high')

      expect(described_class.auto_assignable(user)).to eq([])
    end

    it 'does not include sent back claims' do
      claim.sent_back!

      expect(described_class.auto_assignable(user)).to eq([])
    end
  end

  describe 'claim assignment' do
    let(:user) { create(:caseworker) }

    it 'does not allow a claim to have multiple live assignments' do
      claim.assignments.create!(user:)
      assignment = claim.assignments.new(user:)

      expect(assignment).not_to be_valid
      expect(assignment.errors.of_kind?(:submission, :taken)).to be(true)
    end
  end

  describe '#formatted_allowed_total' do
    context 'granted' do
      it 'adjusted cost if adjusted more than claimed' do
        claim = create(:claim, :increase_adjustment)
        claim.state = Claim::GRANTED
        expect(claim.formatted_allowed_total).to be > claim.formatted_claimed_total
      end

      it 'claimed cost if adjusted less than claimed' do
        claim = create(:claim, :decrease_adjustment)
        claim.state = Claim::GRANTED
        expect(claim.formatted_allowed_total).to eq claim.formatted_claimed_total
      end
    end

    context 'rejected' do
      it '£0.00 for rejected claims' do
        claim.state = Claim::REJECTED
        expect(claim.formatted_allowed_total).to eq '£0.00'
      end
    end

    context 'part_grant' do
      it 'returns adjusted total' do
        claim = create(:claim, :increase_adjustment)
        claim.state = Claim::PART_GRANT
        expect(claim.formatted_allowed_total).to be > claim.formatted_claimed_total
      end
    end
  end
end
