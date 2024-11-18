require 'rails_helper'

RSpec.describe 'Adjustments', :stub_oauth_token do
  let(:caseworker) { create(:caseworker) }
  let(:application) do
    build(:prior_authority_application,
          state: 'submitted',
          data: build(:prior_authority_data,
                      laa_reference: 'LAA-1234',
                      additional_costs: [build(:additional_cost, description: 'Postage stamps')]))
  end
  let(:cost_adjustment_button_label) { 'Adjust additional cost' }

  before do
    stub_app_store_interactions(application)
    sign_in caseworker
    visit '/'
    click_on 'Accept analytics cookies'
  end

  context 'when application is not assigned to me' do
    it 'does not give me the option to adjust it' do
      visit prior_authority_application_adjustments_path(application)
      expect(page).to have_no_content cost_adjustment_button_label
    end
  end

  context 'when application is assigned to me' do
    before do
      application.assigned_user_id = caseworker.id
      application.state = 'submitted'
    end

    it 'shows the application adjustments overview' do
      visit prior_authority_application_adjustments_path(application)
      expect(page).to have_content 'Postage stamps'
    end

    it 'shows an error if I make an adjustment without an explanation' do
      visit prior_authority_application_adjustments_path(application)
      click_on cost_adjustment_button_label
      fill_in 'Hours', with: '3'
      click_on 'Save changes'

      expect(page).to have_content 'Explain your decision for adjusting the costs'
    end

    it 'lets me adjust an additional cost' do
      visit prior_authority_application_adjustments_path(application)
      click_on cost_adjustment_button_label
      fill_in 'Hours', with: '3'
      fill_in 'Minutes', with: '17'
      fill_in 'Explain your decision', with: 'typoe'
      click_on 'Save changes'
      expect(page).to have_content '3 hours 17 minutes'
    end

    it 'updates the total at the top of the page' do
      visit prior_authority_application_path(application)
      expect(page).to have_content 'Requested: £356.50'
      click_on 'Adjust quote'
      expect(page).to have_content 'Amount1 hour 0 minutesRate£32.00 per hour'
      click_on cost_adjustment_button_label
      fill_in 'Minutes', with: '30'
      fill_in 'Explain your decision', with: 'Feeling generous'
      click_on 'Save changes'
      expect(page).to have_content 'Requested: £356.50'
      expect(page).to have_content 'Allowed: £372.50'
    end

    it 'does not change the requested value even if I make multiple adjustments' do
      visit prior_authority_application_adjustments_path(application)
      click_on cost_adjustment_button_label
      fill_in 'Minutes', with: '30'
      fill_in 'Explain your decision', with: 'Feeling generous'
      click_on 'Save changes'

      click_on cost_adjustment_button_label
      fill_in 'Minutes', with: '15'
      fill_in 'Explain your decision', with: 'Feeling less generous'
      click_on 'Save changes'

      expect(page).to have_content 'Requested: £356.50'
    end

    context 'when application is already assessed' do
      before do
        application.state = 'granted'
        application.app_store_updated_at = 1.day.ago
      end

      it 'does not give me the option to adjust it' do
        visit prior_authority_application_adjustments_path(application)
        expect(page).to have_no_content cost_adjustment_button_label
      end
    end
  end
end
