require 'rails_helper'

RSpec.describe 'Overview', type: :system do
  let(:user) { create(:caseworker) }
  let(:claim) { create(:claim) }

  before do
    sign_in user
    create(:assignment, submission: claim, user: user)
    visit nsm_claim_claim_details_path(claim)
  end

  context 'when claim has been submitted' do
    it 'shows me the total claimed but not adjusted' do
      expect(page).to have_content('Claimed: £325.97')
        .and have_no_content('Allowed:')
    end
  end

  context 'when I have made a change' do
    before do
      visit nsm_claim_disbursements_path(claim)
      click_on 'Change'
      fill_in 'Change disbursement cost', with: '0'
      fill_in 'Explain your decision', with: 'Testing'
      click_on 'Save changes'
    end

    it 'shows me the total claimed and total adjusted' do
      expect(page).to have_content('Claimed: £325.97')
        .and have_content('Allowed: £225.97')
    end
  end

  context 'when claim has been assessed' do
    let(:claim) { create(:claim, state: 'granted') }

    it 'shows me the total claimed and total adjusted' do
      expect(page).to have_content('Claimed: £325.97')
        .and have_content('Allowed: £325.97')
    end
  end
end
