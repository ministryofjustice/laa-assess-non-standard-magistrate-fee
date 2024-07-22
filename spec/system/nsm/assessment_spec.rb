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
    before do
      visit nsm_claim_claim_details_path(claim)
      click_link_or_button 'Make a decision'
      choose 'Grant it'
      fill_in 'nsm-make-decision-form-grant-comment-field', with: 'Test Data'
    end

    it 'sends a granted notification' do
      expect { click_link_or_button 'Submit decision' }.to have_enqueued_job(NotifyAppStore)
    end

    context 'when a claim has been granted' do
      before { click_link_or_button 'Submit decision' }

      it 'shows comment on overview page' do
        visit nsm_claim_claim_details_path(claim)
        expect(page).to have_content 'Test Data'
      end

      it 'shows comment on history page' do
        visit nsm_claim_history_path(claim)
        expect(page).to have_content 'Test Data'
      end
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

  context 'further information required' do
    it 'sends a notification' do
      visit nsm_claim_claim_details_path(claim)
      click_link_or_button 'Send back to provider'
      fill_in 'Explain your decision', with: 'Test Data'

      expect do
        click_link_or_button 'Send back to provider'
      end.to have_enqueued_job(NotifyAppStore)
    end
  end

  context 'Review and Adjust' do
    it 'correctly scrolls to a selected row', :javascript do
      page_index = 3
      row_index = 95
      visit nsm_claim_adjustments_path(claim)
      page.execute_script('document.querySelector("turbo-frame").scrollIntoView()')

      click_link_or_button 'Work items'
      find(".govuk-pagination a[href$='page=#{page_index}']", wait: 5).click
      find("tr.govuk-table__row:nth-child(#{row_index}) .govuk-table__header a").click

      expect(page).to have_current_path edit_nsm_claim_work_item_path(claim, claim.data['work_items'][0]['id'])
      sleep(0.5)
      expect(page.evaluate_script("window.sessionStorage.getItem('jumpPage') == '#{page_index}'")).to be true
      expect(page.evaluate_script("window.sessionStorage.getItem('jumpIndex') == '#{row_index}'")).to be true

      click_link_or_button 'Back'
      expect(page).to have_current_path nsm_claim_adjustments_path(claim)
      sleep(0.5)
      expect(page.evaluate_script("window.sessionStorage.getItem('jumpPage') == null")).to be true
      expect(page.evaluate_script("window.sessionStorage.getItem('jumpIndex') == null")).to be true
    end
  end
end
