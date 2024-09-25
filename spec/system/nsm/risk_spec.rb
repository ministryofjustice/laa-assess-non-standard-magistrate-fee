require 'rails_helper'

RSpec.describe 'Risk', :stub_oauth_token do
  let(:user) { create(:caseworker) }
  let(:claim) { create(:claim) }
  let(:stub) do
    stub_request(:patch, "https://appstore.example.com/v1/submissions/#{claim.id}/metadata").to_return(status:)
  end
  let(:status) { 200 }

  before do
    sign_in user
    create(:assignment, submission: claim, user: user)
    stub
    visit open_nsm_claims_path
    click_on claim.data['laa_reference']
    expect(page).to have_content 'Low risk'
    click_on 'Change risk'
  end

  it 'lets me change the risk' do
    choose 'Medium risk'
    fill_in 'Explain your decision', with: 'Looks shifty to me'
    click_on 'Change risk'
    expect(page).to have_content 'You changed the claim risk to medium'
    expect(stub).to have_been_requested
  end

  it 'prevents me changing the risk without a reason' do
    choose 'Medium risk'
    click_on 'Change risk'
    expect(page).to have_content "There is a problem on this page\nExplain why you are changing the risk"
  end

  it 'lets me cancel' do
    click_on 'Cancel'
    expect(page).to have_current_path nsm_claim_claim_details_path(claim)
    expect(page).to have_content 'Low risk'
  end

  context 'when app store errors out' do
    let(:status) { 500 }

    it 'errors out' do
      choose 'Medium risk'
      fill_in 'Explain your decision', with: 'Looks shifty to me'
      click_on 'Change risk'
      expect(page).to have_content 'There was a problem saving the change. Please try again.'
    end
  end
end
