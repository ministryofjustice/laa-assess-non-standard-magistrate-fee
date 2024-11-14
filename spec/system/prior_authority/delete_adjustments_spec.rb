require 'rails_helper'

RSpec.describe 'Delete adjustments', :stub_oauth_token do
  let(:caseworker) { create(:caseworker) }
  let(:application) do
    build(
      :prior_authority_application,
      state: 'submitted',
      data: build(
        :prior_authority_data,
        laa_reference: 'LAA-1234',
        quotes: [
          build(:primary_quote),
          build(:alternative_quote)
        ],
        additional_costs: [
          build(
            :additional_cost,
            name: 'Mileage',
            description: 'fuel is expensive',
            unit_type: 'per_item',
            items: 110,
            cost_per_item: '3.5'
          ),
        ],
      )
    )
  end

  before do
    stub_app_store_interactions(application)
    sign_in caseworker
    visit '/'
    click_on 'Accept analytics cookies'

    application.assigned_user_id = caseworker.id

    visit prior_authority_application_path(application)
    click_on 'Adjust quote'
  end

  context 'when I have adjusted an additional cost' do
    before do
      click_on 'Adjust additional cost'
      fill_in 'Number of items', with: 100
      fill_in 'Cost per item', with: '3.26'
      fill_in 'Explain your decision', with: 'additional cost 1 explanation'
      click_on 'Save changes'

      expect(page).to have_current_path prior_authority_application_adjustments_path(application)
      expect(page).to have_content '£3.26'
      expect(page).to have_content 'additional cost 1 explanation'
    end

    it 'lets me undo my adjustment' do
      click_on 'Delete additional cost adjustment'
      expect(page).to have_content 'Are you sure you want to delete this adjustment?'
      click_on 'Yes, delete it'
      expect(page).to have_current_path prior_authority_application_adjustments_path(application)
      expect(page).to have_no_content '£3.26'
      expect(page).to have_no_content 'additional cost 1 explanation'
    end

    it 'lets me cancel my undo' do
      click_on 'Delete additional cost adjustment'
      expect(page).to have_content 'Are you sure you want to delete this adjustment?'
      click_on 'No, do not delete it'
      expect(page).to have_current_path prior_authority_application_adjustments_path(application)
      expect(page).to have_content '£3.26'
      expect(page).to have_content 'additional cost 1 explanation'
    end
  end

  context 'when I have adjusted the travel cost' do
    before do
      click_on 'Adjust travel costs'
      fill_in 'Hours', with: 1
      fill_in 'Minutes', with: 37
      fill_in 'Explain your decision', with: 'travel cost adjustment explanation'
      click_on 'Save changes'

      expect(page).to have_current_path prior_authority_application_adjustments_path(application)
      expect(page).to have_content '1 hour 37 minutes'
      expect(page).to have_content 'travel cost adjustment explanation'
    end

    it 'lets me undo my adjustment' do
      click_on 'Delete travel cost adjustment'
      expect(page).to have_content 'Are you sure you want to delete this adjustment?'
      click_on 'Yes, delete it'
      expect(page).to have_current_path prior_authority_application_adjustments_path(application)
      expect(page).to have_no_content '1 hour 37 minutes'
      expect(page).to have_no_content 'travel cost adjustment explanation'
    end

    it 'lets me cancel my undo' do
      click_on 'Delete travel cost adjustment'
      expect(page).to have_content 'Are you sure you want to delete this adjustment?'
      click_on 'No, do not delete it'
      expect(page).to have_current_path prior_authority_application_adjustments_path(application)
      expect(page).to have_content '1 hour 37 minutes'
      expect(page).to have_content 'travel cost adjustment explanation'
    end
  end

  context 'when I have adjusted the service cost' do
    before do
      click_on 'Adjust service costs'
      fill_in 'Number of pages', with: 427
      fill_in 'Explain your decision', with: 'adjustment explanation'
      click_on 'Save changes'

      expect(page).to have_current_path prior_authority_application_adjustments_path(application)
      expect(page).to have_content '427'
      expect(page).to have_content 'adjustment explanation'
    end

    it 'lets me undo my adjustment' do
      click_on 'Delete service cost adjustment'
      expect(page).to have_content 'Are you sure you want to delete this adjustment?'
      click_on 'Yes, delete it'
      expect(page).to have_current_path prior_authority_application_adjustments_path(application)
      expect(page).to have_no_content '427'
      expect(page).to have_no_content 'adjustment explanation'
    end

    it 'lets me cancel my undo' do
      click_on 'Delete service cost adjustment'
      expect(page).to have_content 'Are you sure you want to delete this adjustment?'
      click_on 'No, do not delete it'
      expect(page).to have_current_path prior_authority_application_adjustments_path(application)
      expect(page).to have_content '427'
      expect(page).to have_content 'adjustment explanation'
    end
  end
end
