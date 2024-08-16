require 'rails_helper'

RSpec.describe Claim do
  let(:claim) { create(:claim) }

  describe '#unassigned' do
    let(:user) { create(:caseworker) }

    it 'does not include claims which have already been assigned' do
      claim.assignments.create(user: create(:caseworker))

      expect(described_class.unassigned(user)).to eq([])
    end

    it 'does not include claims the user has been unassigned from' do
      Event::Unassignment.build(submission: claim, user: user, current_user: user, comment: 'test')

      expect(described_class.unassigned(user)).to eq([])
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

  describe '#rejected?' do
    it 'if rejected is true' do
      claim.state = Nsm::MakeDecisionForm::REJECTED
      expect(claim).to be_rejected
    end
  end

  describe '#granted?' do
    it 'if granted is true' do
      claim.state = Nsm::MakeDecisionForm::GRANTED
      expect(claim).to be_granted
    end
  end

  describe '#formatted_allowed_total' do
    context 'granted' do
      it 'gross_cost if claim less than allowed' do
        allowed_more = create(:claim, :increase_adjustment)
        allowed_more.state = Nsm::MakeDecisionForm::GRANTED

        expect(allowed_more.formatted_allowed_total).to eq '£355.97'
      end
    end

    context 'rejected' do
      it '£0.00 for rejected claims' do
        claim.state = Nsm::MakeDecisionForm::REJECTED
        expect(claim.formatted_allowed_total).to eq '£0.00'
      end
    end

    context 'part_grant' do
      it 'allowed_gross_cost' do
        claim.state = Nsm::MakeDecisionForm::PART_GRANT
        expect(claim.formatted_allowed_total).to eq '£325.97'
      end
    end
  end
end
