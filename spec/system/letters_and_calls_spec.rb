require 'rails_helper'

RSpec.describe 'Letters and Calls' do
  let(:user) { create(:caseworker) }
  let(:claim) { create(:claim) }

  before { sign_in user }

  it 'can adjust a letter record' do
    visit claim_letters_and_calls_path(claim)

    within('.govuk-table__row', text: 'Letters') do
      expect(page).to have_content(
        'Letters' \
        '12' \
        '95%' \
        '£83.30' \
        'Change'
      )
      click_on 'Change'
    end

    choose 'Yes, remove uplift'
    fill_in 'Change number of letters', with: '22'
    fill_in 'Explain your decision', with: 'Testing'

    click_on 'Save changes'

    # need to access page directly as not JS enabled
    visit claim_letters_and_calls_path(claim)

    within('.govuk-table__row', text: 'Letters') do
      expect(page).to have_content(
        'Letters' \
        '22' \
        '95%' \
        '£83.30' \
        '0%' \
        '£78.32' \
        'Change'
      )
    end
  end

  it 'can adjust a letter record' do
    visit claim_letters_and_calls_path(claim)

    within('.govuk-table__row', text: 'Calls') do
      expect(page).to have_content(
        'Calls' \
        '4' \
        '20%' \
        '£17.09' \
        'Change'
      )
      click_on 'Change'
    end

    choose 'Yes, remove uplift'
    fill_in 'Change number of calls', with: '22'
    fill_in 'Explain your decision', with: 'Testing'

    click_on 'Save changes'

    # need to access page directly as not JS enabled
    visit claim_letters_and_calls_path(claim)

    within('.govuk-table__row', text: 'Calls') do
      expect(page).to have_content(
        'Calls' \
        '22' \
        '20%' \
        '£17.09' \
        '0%' \
        '£78.32' \
        'Change'
      )
    end
  end

  it 'can remove all uplift' do
    visit claim_letters_and_calls_path(claim)

    click_on 'Remove uplifts for all items'

    fill_in 'Explain your decision', with: 'Testing'

    click_on 'Yes, remove all uplift'

    # need to access page directly as not JS enabled
    visit claim_letters_and_calls_path(claim)

    within('.govuk-table__row', text: 'Letters') do
      expect(page).to have_content(
        'Letters' \
        '12' \
        '95%' \
        '£83.30' \
        '0%' \
        '£42.72' \
        'Change'
      )
    end
    within('.govuk-table__row', text: 'Calls') do
      expect(page).to have_content(
        'Calls' \
        '4' \
        '20%' \
        '£17.09' \
        '0%' \
        '£14.24' \
        'Change'
      )
    end
  end
end