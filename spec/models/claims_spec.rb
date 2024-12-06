require 'rails_helper'

RSpec.describe Claim do
  let(:claim) { build(:claim, state:, data:) }
  let(:data) { build(:nsm_data) }
  let(:state) { Claim::GRANTED }

  describe '#formatted_allowed_total' do
    context 'granted' do
      let(:state) { Claim::GRANTED }

      context 'increased adjustment' do
        let(:data) { build(:nsm_data, :increase_adjustment) }

        it 'adjusted cost if adjusted more than claimed' do
          expect(claim.formatted_allowed_total > claim.formatted_claimed_total).to eq true
        end
      end

      context 'decreased adjustment' do
        let(:data) { build(:nsm_data, :decrease_adjustment) }

        it 'claimed cost if adjusted less than claimed' do
          expect(claim.formatted_allowed_total).to eq claim.formatted_claimed_total
        end
      end
    end

    context 'rejected' do
      let(:state) { Claim::REJECTED }

      it '£0.00 for rejected claims' do
        expect(claim.formatted_allowed_total).to eq '£0.00'
      end
    end

    context 'part_grant' do
      let(:state) { Claim::PART_GRANT }
      let(:data) { build(:nsm_data, :increase_adjustment) }

      it 'returns adjusted total' do
        expect(claim.formatted_allowed_total).to be > claim.formatted_claimed_total
      end
    end
  end
end
