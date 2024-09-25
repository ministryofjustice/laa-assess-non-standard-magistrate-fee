require 'rails_helper'

Rails.describe 'Assessment', :stub_oauth_token, :stub_update_claim do
  let(:fixed_arbitrary_date) { DateTime.new(2024, 7, 4, 12, 3, 12) }
  let(:user) { create(:caseworker) }
  let(:claim) { create(:claim) }

  before do
    sign_in user
    create(:assignment, submission: claim, user: user)
    visit '/'
    click_on 'Accept analytics cookies'
  end

  context 'when granted' do
    before do
      travel_to fixed_arbitrary_date
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

      it 'shows assessment date on overview page' do
        visit nsm_claim_claim_details_path(claim)
        expect(page).to have_content 'Date assessed: 4 July 2024'
      end

      it 'shows comment on history page' do
        visit nsm_claim_history_path(claim)
        expect(page).to have_content 'Test Data'
      end
    end
  end

  context 'when part-granted' do
    let(:claim) { create(:claim, :with_reduced_work_item) }

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

  context 'when rejected' do
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

  context 'when further information required' do
    before do
      travel_to fixed_arbitrary_date
      visit nsm_claim_claim_details_path(claim)
      click_link_or_button 'Send back to provider'
      fill_in 'Explain your decision', with: 'Test Data'
    end

    it 'sends a notification' do
      expect do
        click_link_or_button 'Send back to provider'
      end.to have_enqueued_job(NotifyAppStore)
    end

    context 'when I have sent a claim back' do
      before { click_link_or_button 'Send back to provider' }

      it 'shows the date on the details page' do
        visit nsm_claim_claim_details_path(claim)

        expect(page).to have_content 'Date sent back to provider: 4 July 2024'
      end

      it 'shows the FI details' do
        visit nsm_claim_claim_details_path(claim)

        expect(page).to have_content "Sent back to provider on 4 July 2024\nTest Data"
      end
    end
  end

  context 'when navigating', :javascript do
    let(:claim) do
      disbursements = Array.new(100) do |i|
        {
          'id' => SecureRandom.uuid,
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
          'disbursement_date' => Date.new(2022, 12, 12) + i,
          'disbursement_type' => {
            'en' => 'Other',
            'value' => 'other'
          },
          'total_cost_without_vat' => 100.0
        }
      end
      work_items = Array.new(200) do |i|
        {
          'id' => SecureRandom.uuid,
          'uplift' => 95,
          'pricing' => 24.0,
          'work_type' => {
            'en' => 'Waiting',
            'value' => 'waiting'
          },
          'fee_earner' => 'aaa',
          'time_spent' => 161,
          'completed_on' => Date.new(2022, 12, 12) + i
        }
      end
      create(:claim, disbursements:, work_items:)
    end

    it 'includes the disbursement ID when navigating back' do
      visit nsm_claim_disbursements_path(claim)

      clicked_id = claim.data['disbursements'][57]['id']
      expect(evaluate_script('window.scrollY')).to eq 0

      find("tbody tr[id=\"#{clicked_id}\"] a").click
      expect(page).to have_content('Adjust a disbursement')

      click_on 'Back'

      expect(page).not_to have_content('Adjust a disbursement')
      expect(current_url).to end_with("##{clicked_id}")
      expect(evaluate_script('window.scrollY')).to be > 0
    end

    it 'includes the work item ID when navigating back' do
      visit nsm_claim_work_items_path(claim)

      clicked_id = claim.data['work_items'][53]['id']
      expect(evaluate_script('window.scrollY')).to eq 0
      find("tbody tr[id=\"#{clicked_id}\"] a", text: 'Waiting').click
      expect(page).to have_content('Adjust a work item')

      click_on 'Back'

      expect(page).not_to have_content('Adjust a work item')
      expect(current_url).to end_with("##{clicked_id}")
      expect(evaluate_script('window.scrollY')).to be > 0
    end
  end
end
