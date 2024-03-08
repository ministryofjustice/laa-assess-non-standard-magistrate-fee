require 'rails_helper'

RSpec.describe 'Adjust service costs' do
  before do
    sign_in caseworker
    visit '/'
    click_on 'Accept analytics cookies'

    create(:assignment,
           user: caseworker,
           submission: application)

    visit prior_authority_root_path
    click_on 'Start now'
    expect(page).to have_content 'LAA-1234'
    click_on 'LAA-1234'
    expect(page).to have_current_path prior_authority_application_path(application)
    click_on 'Adjust quote'
    expect(page).to have_title('Adjustments')
    click_on 'Adjust service costs'
    expect(page).to have_title('Adjust service costs')
  end

  let(:caseworker) { create(:caseworker) }

  context 'with a per hour service cost' do
    let(:application) do
      create(
        :prior_authority_application,
        state: 'in_progress',
        data: build(
          :prior_authority_data,
          laa_reference: 'LAA-1234',
          service_type: 'pathologist_report',
          quotes: [
            build(
              :primary_quote,
              cost_type: 'per_hour',
              item_type: 'item',
              period: 180,
              cost_per_hour: '3.50',
              travel_time: nil,
              travel_cost_per_hour: nil,
              travel_cost_reason: nil,
            ),
            build(:alternative_quote)
          ],
          additional_costs: [],
        )
      )
    end

    it 'allows me to adjust the Time spent' do
      expect(page).to have_content('Pathologist report cost')

      fill_in 'Hours', with: 10
      fill_in 'Minutes', with: 30
      fill_in 'Explain your decision', with: 'they worked longer'
      click_on 'Save changes'

      expect(page).to have_title('Adjustments')
      within('.govuk-table#service_costs') do
        expect(page)
          .to have_content('Amount3 hours 0 minutes10 hours 30 minutes')
          .and have_content('Cost£3.50 per hour£3.50 per hour')
          .and have_content('Total£10.50£36.75')
      end
    end

    it 'allows me to adjust the cost per hour' do
      fill_in 'Hourly cost', with: '5.50'
      fill_in 'Explain your decision', with: 'rates have risen'
      click_on 'Save changes'

      expect(page).to have_title('Adjustments')

      within('.govuk-table#service_costs') do
        expect(page)
          .to have_content('Amount3 hours 0 minutes3 hours 0 minutes')
          .and have_content('Cost£3.50 per hour£5.50 per hour')
          .and have_content('Total£10.50£16.50')
      end
    end

    it 'allows me to recalculate the values on the page', :javascript do
      fill_in 'Hours', with: 20
      fill_in 'Minutes', with: 0
      fill_in 'Hourly cost', with: '1.50'

      click_on 'Calculate my changes'
      expect(page).to have_css('#adjusted-cost', text: '30.00')
    end

    it 'warns me that I have not made any changes' do
      fill_in 'Explain your decision', with: 'rates have risen'
      click_on 'Save changes'

      expect(page).to have_title('Adjust service costs')
      expect(page).to have_content('There are no changes to save. ' \
                                   'Select cancel if you do not want to make any changes.')
    end

    it 'allows me to cancel and return to adjustments page' do
      click_on 'Cancel'
      expect(page).to have_title('Adjustments')
    end
  end

  context 'with a per item service cost' do
    let(:application) do
      create(
        :prior_authority_application,
        state: 'in_progress',
        data: build(
          :prior_authority_data,
          laa_reference: 'LAA-1234',
          service_type: 'translation_and_transcription',
          quotes: [
            build(
              :primary_quote,
              cost_type: 'per_item',
              item_type: 'minute',
              items: 100,
              cost_per_item: '2.00',
            ),
            build(:alternative_quote)
          ],
          additional_costs: [],
        )
      )
    end

    it 'allows me to adjust the Number of items (minutes)' do
      expect(page).to have_content('Translation and transcription cost')

      fill_in 'Number of minutes', with: 60
      fill_in 'Explain your decision', with: '1 hour maximum allowed'
      click_on 'Save changes'

      expect(page).to have_title('Adjustments')
      within('.govuk-table#service_costs') do
        expect(page)
          .to have_content('Amount100 minutes60 minutes')
          .and have_content('Cost£2.00 per minute£2.00 per minute')
          .and have_content('Total£200.00£120.00')
      end
    end

    it 'allows me to adjust the Cost per item (minute)' do
      fill_in 'What is the cost per minute?', with: 1.50
      fill_in 'Explain your decision', with: '£1.50 per minute maximum allowed'
      click_on 'Save changes'

      expect(page).to have_title('Adjustments')
      within('.govuk-table#service_costs') do
        expect(page)
          .to have_content('Amount100 minutes100 minutes')
          .and have_content('Cost£2.00 per minute£1.50 per minute')
          .and have_content('Total£200.00£150.00')
      end
    end

    it 'allows me to calculate the values on the page', :javascript do
      fill_in 'Number of minutes', with: 60
      fill_in 'What is the cost per minute?', with: 2.50

      click_on 'Calculate my changes'
      expect(page).to have_css('#adjusted-cost', text: '150.00')
    end
  end
end
