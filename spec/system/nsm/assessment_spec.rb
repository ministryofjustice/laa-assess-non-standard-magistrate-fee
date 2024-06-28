require 'rails_helper'

Rails.describe 'Assessment', :stub_oauth_token, :stub_update_claim do
  let(:user) { create(:caseworker) }
  let(:claim) { create(:claim) }

  before do
    sign_in user
    create(:assignment, submission: claim, user: user)
    visit '/'
    click_on 'Accept analytics cookies'
  end

  context 'granted' do
    it 'sends a granted notification' do
      visit nsm_claim_claim_details_path(claim)
      click_link_or_button 'Make a decision'
      choose 'Grant it'
      fill_in 'nsm-make-decision-form-grant-comment-field', with: 'Test Data'

      expect do
        click_link_or_button 'Submit decision'
      end.to have_enqueued_job(NotifyAppStore)

      visit nsm_claim_history_path(claim)
      expect(page).to have_content 'Test Data'
    end
  end

  context 'part-granted' do
    it 'sends a part granted notification' do
      visit nsm_claim_claim_details_path(claim)
      click_link_or_button 'Make a decision'
      choose 'Part grant it'
      fill_in 'nsm-make-decision-form-partial-comment-field', with: 'Test Data'

      expect do
        click_link_or_button 'Submit decision'
      end.to have_enqueued_job(NotifyAppStore)
    end
  end

  context 'rejected' do
    it 'sends a rejected notification' do
      visit nsm_claim_claim_details_path(claim)
      click_link_or_button 'Make a decision'
      choose 'Reject it'
      fill_in 'nsm-make-decision-form-reject-comment-field', with: 'Test Data'

      expect do
        click_link_or_button 'Submit decision'
      end.to have_enqueued_job(NotifyAppStore)
    end
  end

  context 'provider requested' do
    context 'when claim is already sent back' do
      before { claim.update(state: 'provider_requested') }

      it 'does not give the option to send back again' do
        visit nsm_claim_claim_details_path(claim)
        expect(page).to have_no_content 'Send back to provider'
      end
    end

    it 'sends a notification' do
      visit nsm_claim_claim_details_path(claim)
      click_link_or_button 'Send back to provider'
      choose 'Provider request'
      fill_in 'Explain your decision', with: 'Test Data'

      expect do
        click_link_or_button 'Send back to provider'
      end.to have_enqueued_job(NotifyAppStore)
    end
  end

  context 'further information required' do
    it 'sends a notification' do
      visit nsm_claim_claim_details_path(claim)
      click_link_or_button 'Send back to provider'
      choose 'Further information request'
      fill_in 'Explain your decision', with: 'Test Data'

      expect do
        click_link_or_button 'Send back to provider'
      end.to have_enqueued_job(NotifyAppStore)
    end
  end
end
