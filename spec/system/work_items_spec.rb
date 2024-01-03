require 'rails_helper'

RSpec.describe 'Work items' do
  let(:user) { create(:caseworker) }
  let(:claim) { create(:claim) }

  before do
    sign_in user
    visit '/'
    click_link 'Accept analytics cookies'
  end

  it 'can adjust a work item record' do
    visit claim_work_items_path(claim)

    within('.govuk-table__row', text: 'Waiting') do
      expect(page).to have_content(
        'Waiting' \
        '95%' \
        '2 Hours41 Minutes' \
        'Change'
      )
      click_link 'Change'
    end

    choose 'Yes, remove uplift'
    fill_in 'Hours', with: '10'
    fill_in 'Minutes', with: '59'
    fill_in 'Explain your decision', with: 'Testing'

    click_button 'Save changes'

    # need to access page directly as not JS enabled
    visit claim_work_items_path(claim)

    within('.govuk-table__row', text: 'Waiting') do
      expect(page).to have_content(
        'Waiting' \
        '95%' \
        '2 Hours41 Minutes' \
        '0%' \
        '10 Hours59 Minutes' \
        'Change'
      )
    end
  end

  it 'can remove all uplift' do
    visit claim_work_items_path(claim)

    click_link 'Remove uplifts for all items'

    fill_in 'Explain your decision', with: 'Testing'

    click_button 'Yes, remove all uplift'

    # need to access page directly as not JS enabled
    visit claim_work_items_path(claim)

    within('.govuk-table__row', text: 'Waiting') do
      expect(page).to have_content(
        'Waiting' \
        '95%' \
        '2 Hours41 Minutes' \
        '0%' \
        '2 Hours41 Minutes' \
        'Change'
      )
    end

    expect(page).not_to have_content('Remove uplifts for all items')
  end
end
