require 'rails_helper'

RSpec.describe 'Assign claims' do
  let(:caseworker) { create(:caseworker) }

  before do
    allow(AppStoreService).to receive_messages(list: [[claim].compact, 1], get: claim, assign: claim)
    allow(AppStoreService).to receive(:unassign)
    sign_in caseworker
    visit nsm_your_claims_path
    click_on 'Assess next claim'
  end

  context 'when there is a claim' do
    let(:claim) { build(:claim) }

    it 'lets me assign the claim to myself' do
      expect(page).to have_current_path nsm_claim_claim_details_path(claim)
    end

    context 'when the claim is already assigned to me' do
      let(:claim) { build(:claim, assigned_user: caseworker) }

      it 'shows the claim in the Your Claims screen' do
        visit nsm_your_claims_path
        expect(page).to have_content claim.data['laa_reference']
      end

      context 'when I try to unassign the claim' do
        before { click_on 'Remove from your list' }

        it 'lets me unassign the claim' do
          fill_in 'Explain your decision', with: 'Too busy'
          click_on 'Yes, remove from list'
          expect(page).to have_content "#{claim.data['laa_reference']} has been removed from your list"
        end

        it 'requires me to enter a reason' do
          click_on 'Yes, remove from list'
          expect(page).to have_content 'Add an explanation for your decision'
        end

        it 'lets me cancel my decision' do
          click_on 'Cancel'
          expect(page).to have_current_path nsm_claim_claim_details_path(claim)
        end
      end
    end
  end

  context 'when there is no claim' do
    let(:claim) { nil }

    it 'shows me an explanation' do
      expect(page).to have_content 'There are no claims waiting to be allocated.'
    end
  end
end
