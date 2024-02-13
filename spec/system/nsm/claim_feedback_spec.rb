require 'rails_helper'

Rails.describe 'Claim Feedback', :stub_oauth_token, :stub_update_claim do
  let(:user) { create(:caseworker) }
  let(:claim) { build(:claim) }

  before do
    allow(AppStoreService).to receive(:list) do |params|
      if params[:assessed]
        [[claim.dup.tap { _1.state = 'granted' }], 1]
      else
        [[claim], 1]
      end
    end

    allow(AppStoreService).to receive_messages(
      get: claim,
      change_state: nil
    )
    sign_in user
    visit '/'
    click_on 'Accept analytics cookies'
  end

  context 'granted' do
    it 'sends a granted email' do
      visit nsm_claim_claim_details_path(claim)
      click_link_or_button 'Make a decision'
      choose 'Grant it'

      expect do
        click_link_or_button 'Submit decision'
      end.to have_enqueued_job.on_queue('mailers')
    end
  end

  context 'part-granted' do
    it 'sends a part granted email' do
      visit nsm_claim_claim_details_path(claim)
      click_link_or_button 'Make a decision'
      choose 'Part grant it'
      fill_in 'nsm-make-decision-form-partial-comment-field', with: 'Test Data'

      expect do
        click_link_or_button 'Submit decision'
      end.to have_enqueued_job.on_queue('mailers')
    end
  end

  context 'rejected' do
    it 'sends a rejected email' do
      visit nsm_claim_claim_details_path(claim)
      click_link_or_button 'Make a decision'
      choose 'Reject it'
      fill_in 'nsm-make-decision-form-reject-comment-field', with: 'Test Data'

      expect do
        click_link_or_button 'Submit decision'
      end.to have_enqueued_job.on_queue('mailers')
    end
  end

  context 'provider requested' do
    it 'sends a granted email' do
      visit nsm_claim_claim_details_path(claim)
      click_link_or_button 'Send back to provider'
      choose 'Provider request'
      fill_in 'Explain your decision', with: 'Test Data'

      expect do
        click_link_or_button 'Send back to provider'
      end.to have_enqueued_job.on_queue('mailers')
    end
  end

  context 'further information required' do
    it 'sends a granted email' do
      visit nsm_claim_claim_details_path(claim)
      click_link_or_button 'Send back to provider'
      choose 'Further information request'
      fill_in 'Explain your decision', with: 'Test Data'

      expect do
        click_link_or_button 'Send back to provider'
      end.to have_enqueued_job.on_queue('mailers')
    end
  end
end
