require 'rails_helper'

RSpec.describe 'Adjust additional costs' do
  before do
    sign_in caseworker
    visit '/'
    click_on 'Accept analytics cookies'

    create(:assignment,
           user: caseworker,
           submission: application)

    visit prior_authority_root_path
    expect(page).to have_content('LAA-1234')
    click_on 'LAA-1234'
    expect(page).to have_current_path(prior_authority_application_path(application))
    click_on 'Adjust quote'
    expect(page).to have_title('Adjustments')
  end

  let(:caseworker) { create(:caseworker) }

  context 'with per item and per hour additional costs' do
    let(:application) do
      create(
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
            build(
              :additional_cost,
              name: 'Waiting time',
              description: 'delayed interview at police station',
              unit_type: 'per_hour',
              period: 120,
              cost_per_hour: '50.0'
            ),
          ],
        )
      )
    end

    it 'allows me to adjust the first additional cost (items)' do
      within('.govuk-table#additional_cost_1') do
        expect(page)
          .to have_content('Item110 items')
          .and have_content('Cost£3.50 per item')
          .and have_content('Total£385.00')
      end

      click_on 'Adjust additional cost', match: :first

      expect(page)
        .to have_title('Adjust additional cost 1')
        .and have_content("Adjust the providers' costs by changing the values.")

      fill_in 'Number of items', with: 100
      fill_in 'What is the cost per item?', with: '3.00'
      fill_in 'Explain your decision', with: 'additional cost 1 explanation'
      click_on 'Save changes'

      expect(page).to have_title('Adjustments')
      expect(page).to have_css('.govuk-inset-text', text: 'additional cost 1 explanation')

      within('.govuk-table#additional_cost_1') do
        expect(page)
          .to have_content('Item110 items100 items')
          .and have_content('Cost£3.50 per item£3.00 per item')
          .and have_content('Total£385.00£300.00')
      end
    end

    it 'allows me to adjust the second additional cost (time)' do
      within('.govuk-table#additional_cost_2') do
        expect(page)
          .to have_content('Time2 hours 0 minutes')
          .and have_content('Cost£50.00 per hour')
          .and have_content('Total£100.00')
      end

      page.click_on(id: 'additional_cost_2', text: 'Adjust additional cost', exact: true)

      expect(page)
        .to have_title('Adjust additional cost 2')
        .and have_content("Adjust the providers' costs by changing the values.")

      fill_in 'Hours', with: 1
      fill_in 'Minutes', with: 30
      fill_in 'What is the hourly cost?', with: '40.00'
      fill_in 'Explain your decision', with: 'additional cost 2 explanation'
      click_on 'Save changes'

      expect(page).to have_title('Adjustments')
      expect(page).to have_css('.govuk-inset-text', text: 'additional cost 2 explanation')

      within('.govuk-table#additional_cost_2') do
        expect(page)
          .to have_content('Time2 hours 0 minutes1 hour 30 minutes')
          .and have_content('Cost£50.00 per hour£40.00 per hour')
          .and have_content('Total£100.00£60.00')
      end
    end

    it 'allows me to recalculate the item cost on the page', :javascript do
      click_on 'Adjust additional cost', match: :first

      expect(page).to have_title('Adjust additional cost 1')

      expect(page).to have_css('#adjusted-cost', text: '0.00')
      fill_in 'Number of items', with: 'a'
      fill_in 'What is the cost per item?', with: 'a'
      click_on 'Calculate my changes'
      expect(page).to have_css('#adjusted-cost', text: '--')

      fill_in 'Number of items', with: 100
      fill_in 'What is the cost per item?', with: '3.00'

      click_on 'Calculate my changes'
      expect(page).to have_css('#adjusted-cost', text: '300.00')
    end

    it 'displays erroroneous values with appropriate message for the first additional cost (item)' do
      click_on 'Adjust additional cost', match: :first

      fill_in 'Number of items', with: ''
      fill_in 'What is the cost per item?', with: ''

      click_on 'Save changes'
      expect(page)
        .to have_content('Enter the number of items')
        .and have_content('Enter the cost per item')

      fill_in 'Number of items', with: 0
      fill_in 'What is the cost per item?', with: 0

      click_on 'Save changes'
      expect(page)
        .to have_content('The number of items must be more than 0')
        .and have_content('The cost per item must be more than 0')

      fill_in 'Number of items', with: 'a'
      fill_in 'What is the cost per item?', with: 'a'

      click_on 'Save changes'
      expect(page)
        .to have_content('The number of items must be a number, like 25')
        .and have_content('The cost per item must be a number, like 25')
        .and have_field('Number of items', with: 'a')
        .and have_field('What is the cost per item?', with: 'a')
    end

    it 'allows me to recalculate the time cost on the page', :javascript do
      page.click_on(id: 'additional_cost_2', text: 'Adjust additional cost', exact: true)

      expect(page).to have_title('Adjust additional cost 2')

      fill_in 'Hours', with: 1
      fill_in 'Minutes', with: 30
      fill_in 'What is the hourly cost?', with: '40.00'

      expect(page).to have_css('#adjusted-cost', text: '0.00')
      click_on 'Calculate my changes'
      expect(page).to have_css('#adjusted-cost', text: '60.00')
    end

    it 'displays erroroneous values with appropriate message for the second additional cost (time)' do
      page.click_on(id: 'additional_cost_2', text: 'Adjust additional cost', exact: true)

      fill_in 'Hours', with: 'a'
      fill_in 'Minutes', with: 'b'
      fill_in 'What is the hourly cost?', with: 'c'

      click_on 'Save changes'

      expect(page)
        .to have_content('The number of hours must be a number')
        .and have_content('The cost per hour must be a number, like 25')
        .and have_field('Hours', with: 'a')
        .and have_field('Minutes', with: 'b')
        .and have_field('What is the hourly cost?', with: 'c')
    end

    it 'warns me that I have not made any changes' do
      click_on 'Adjust additional cost', match: :first
      fill_in 'Explain your decision', with: 'maximum exceeded'
      click_on 'Save changes'

      expect(page).to have_title('Adjust additional cost 1')
      expect(page).to have_content('There are no changes to save. ' \
                                   'Select cancel if you do not want to make any changes.')
    end

    it 'allows me to cancel and return to adjustments page' do
      click_on 'Adjust additional cost', match: :first
      click_on 'Cancel'
      expect(page).to have_title('Adjustments')
    end
  end
end
