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

  context 'navigation', :javascript do
    let(:claim) do
      disbursement = {
        'id' => '1c0f36fd-fd39-498a-823b-0a3837454563',
        'details' => 'Details',
        'pricing' => 1.0,
        'vat_rate' => 0.2,
        'apply_vat' => 'false',
        'other_type' => {
          'en' => 'Apples',
          'value' => 'Apples'
        },
        'vat_amount' => 0.0,
        'prior_authority' => 'yes',
        'disbursement_date' => '2022-12-12',
        'disbursement_type' => {
          'en' => 'Other',
          'value' => 'other'
        },
        'total_cost_without_vat' => 100.0
      }
      work_item = {
        'id' => 'cf5e303e-98dd-4b0f-97ea-3560c4c5f137',
          'uplift' => 95,
          'pricing' => 24.0,
          'work_type' => {
            'en' => 'Waiting',
            'value' => 'waiting'
          },
          'fee_earner' => 'aaa',
          'time_spent' => 161,
          'completed_on' => '2022-12-12'
      }
      create(:claim, disbursements: Array.new(200, disbursement), work_items: Array.new(200, work_item))
    end

    it 'includes the disbursement ID when navigating back' do
      visit nsm_claim_disbursements_path(claim)

      find('tbody tr:nth-child(8) a').click

      click_link_or_button 'Back'

      expect(current_url).to end_with "##{claim.data['disbursements'][0]['id']}"
    end

    it 'includes the work item ID when navigating back' do
      visit nsm_claim_work_items_path(claim)

      find('tbody tr:nth-child(8) a').click

      click_link_or_button 'Back'

      expect(current_url).to end_with "##{claim.data['work_items'][0]['id']}"
    end
  end
end
