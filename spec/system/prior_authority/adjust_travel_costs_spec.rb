require 'rails_helper'

RSpec.describe 'Adjust travel costs', :stub_oauth_token do
  before do
    stub_app_store_interactions(application)
    sign_in caseworker
    visit '/'
    click_on 'Accept analytics cookies'

    application.assigned_user_id = caseworker.id

    visit prior_authority_application_path(application)
    click_on 'Adjust quote'
    expect(page).to have_title('Adjustments')
    click_on 'Adjust travel costs'
    expect(page).to have_title('Adjust travel costs')
  end

  let(:caseworker) { create(:caseworker) }

  let(:application) do
    build(
      :prior_authority_application,
      state: 'submitted',
      data: build(
        :prior_authority_data,
        laa_reference: 'LAA-1234',
        service_type: 'pathologist_report',
        quotes: [
          build(
            :primary_quote,
            cost_type: 'per_hour',
            period: 180,
            cost_per_hour: '3.50',
            travel_time: 90,
            travel_cost_per_hour: '100.00',
            travel_cost_reason: 'Client detained in prison',
          ),
          build(:alternative_quote)
        ],
        additional_costs: [],
      )
    )
  end

  it 'allows me to adjust the travel time' do
    fill_in 'Hours', with: 1
    fill_in 'Minutes', with: 0
    fill_in 'Explain your decision', with: 'travel cost adjustment explanation'
    click_on 'Save changes'

    expect(page).to have_title('Adjustments')
    expect(page).to have_css('.govuk-inset-text', text: 'travel cost adjustment explanation')

    within('.govuk-table#travel_costs') do
      expect(page)
        .to have_content('Amount1 hour 30 minutes1 hour 0 minutes')
        .and have_content('Rate£100.00 per hour£100.00 per hour')
        .and have_content('Total£150.00£100.0')
    end
  end

  it 'allows me to adjust the cost per hour' do
    fill_in 'Cost per hour', with: '90.00'
    fill_in 'Explain your decision', with: 'travel cost adjustment explanation'
    click_on 'Save changes'

    expect(page).to have_title('Adjustments')
    expect(page).to have_css('.govuk-inset-text', text: 'travel cost adjustment explanation')

    within('.govuk-table#travel_costs') do
      expect(page)
        .to have_content('Amount1 hour 30 minutes1 hour 30 minutes')
        .and have_content('Rate£100.00 per hour£90.00 per hour')
        .and have_content('Total£150.00£135.0')
    end
  end

  it 'warns me that I have not made any changes' do
    fill_in 'Explain your decision', with: 'oops!'
    click_on 'Save changes'

    expect(page).to have_title('Adjust travel costs')
    expect(page).to have_content('There are no changes to save. ' \
                                 'Select cancel if you do not want to make any changes.')
  end

  it 'allows me to cancel and return to adjustments page' do
    click_on 'Cancel'
    expect(page).to have_title('Adjustments')
  end

  it 'allows me to recalculate the values on the page', :javascript do
    fill_in 'Hours', with: 2
    fill_in 'Minutes', with: 0
    fill_in 'Cost per hour', with: '100.00'

    expect(page).to have_css('#adjusted-cost', text: '0.00')
    click_on 'Calculate my changes'
    expect(page).to have_css('#adjusted-cost', text: '200.00')
  end
end
