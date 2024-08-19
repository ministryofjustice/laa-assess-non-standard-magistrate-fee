require 'rails_helper'

RSpec.describe 'Overview', type: :system do
  let(:user) { create(:caseworker) }
  let(:claim) { create(:claim) }

  before do
    sign_in user
    create(:assignment, submission: claim, user: user)
  end

  context 'when claim has been submitted' do
    before { visit nsm_claim_claim_details_path(claim) }

    it 'shows me the total claimed but not adjusted' do
      expect(page)
        .to have_content('Claimed: £325.97')
        .and have_no_content('Allowed:')
    end
  end

  context 'when I have made a change' do
    before do
      visit nsm_claim_disbursements_path(claim)
      click_on 'Apples'
      fill_in 'Change disbursement cost', with: '0'
      fill_in 'Explain your decision', with: 'Testing'
      click_on 'Save changes'
    end

    it 'shows me the total claimed and total adjusted' do
      expect(page)
        .to have_content('Claimed: £325.97')
        .and have_content('Allowed: £225.97')
    end
  end

  context 'when claim has been assessed as granted' do
    before { visit nsm_claim_claim_details_path(claim) }

    let(:claim) { create(:claim, state: 'granted') }

    it 'shows me the total claimed and total adjusted' do
      expect(page)
        .to have_content('Claimed: £325.97')
        .and have_content('Allowed: £325.97')
    end
  end

  context 'when claim has been assessed as part granted' do
    let(:claim) { create(:claim, state: 'part_grant') }
    let(:part_grant_event) { create(:event, :part_granted, claim: claim, details: { comment: 'Part grant reason' }) }

    before do
      part_grant_event
      visit nsm_claim_claim_details_path(claim)
    end

    it 'shows me the decision, comment and review adjustments link' do
      expect(page)
        .to have_selector('strong', text: 'Part granted')
        .and have_content(part_grant_event.details['comment'])
        .and have_link('Review quote adjustments')
    end
  end
end
