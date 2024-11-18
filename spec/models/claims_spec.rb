require 'rails_helper'

RSpec.describe Claim do
  let(:claim) { build(:claim) }

  describe '#formatted_allowed_total' do
    context 'granted' do
      it 'adjusted cost if adjusted more than claimed' do
        claim = build(:claim, :increase_adjustment)
        claim.state = Claim::GRANTED
        expect(claim.formatted_allowed_total).to be > claim.formatted_claimed_total
      end

      it 'claimed cost if adjusted less than claimed' do
        claim = build(:claim, :decrease_adjustment)
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
        claim = build(:claim, :increase_adjustment)
        claim.state = Claim::PART_GRANT
        expect(claim.formatted_allowed_total).to be > claim.formatted_claimed_total
      end
    end
  end
end
