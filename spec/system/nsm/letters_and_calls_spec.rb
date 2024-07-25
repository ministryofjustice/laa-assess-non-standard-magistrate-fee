require 'rails_helper'

RSpec.describe 'Letters and Calls' do
  let(:user) { create(:caseworker) }
  let(:claim) { create(:claim) }

  before do
    sign_in user
    create(:assignment, submission: claim, user: user)
    visit '/'
    click_on 'Accept analytics cookies'
  end

  it 'can adjust a letter record' do
    visit nsm_claim_letters_and_calls_path(claim)

    within('.govuk-table__row', text: 'Letters') do
      expect(page).to have_content(
        'Letters' \
        '12' \
        '95%' \
        '£83.30'
      )
      click_on 'Letters'
    end

    choose 'Yes, remove uplift'
    fill_in 'Change number of letters', with: '22'
    fill_in 'Explain your decision', with: 'Testing'

    click_on 'Save changes'

    within('.govuk-table__row', text: 'Letters') do
      expect(page).to have_content(
        'Letters' \
        '12' \
        '95%' \
        '£83.30' \
        '£78.32'
      )
    end

    visit adjusted_nsm_claim_letters_and_calls_path(claim)

    within('.govuk-table__row', text: 'Letters') do
      expect(page).to have_content(
        'Letters' \
        'Testing' \
        '22' \
        '0%' \
        '£78.32'
      )
    end
  end

  it 'can adjust a call record' do
    visit nsm_claim_letters_and_calls_path(claim)

    within('.govuk-table__row', text: 'Calls') do
      expect(page).to have_content(
        'Calls' \
        '4' \
        '20%' \
        '£17.09'
      )
      click_on 'Calls'
    end

    choose 'Yes, remove uplift'
    fill_in 'Change number of calls', with: '22'
    fill_in 'Explain your decision', with: 'Testing'

    click_on 'Save changes'

    within('.govuk-table__row', text: 'Calls') do
      expect(page).to have_content(
        'Calls' \
        '4' \
        '20%' \
        '£17.09' \
        '£78.32'
      )
    end
  end

  it 'can remove all uplift' do
    visit nsm_claim_letters_and_calls_path(claim)

    click_on 'Remove uplifts for all items'

    fill_in 'Explain your decision', with: 'Testing'

    click_on 'Yes, remove all uplift'

    within('.govuk-table__row', text: 'Letters') do
      expect(page).to have_content(
        'Letters' \
        '12' \
        '95%' \
        '£83.30' \
        '£42.72'
      )
    end

    within('.govuk-table__row', text: 'Calls') do
      expect(page).to have_content(
        'Calls' \
        '4' \
        '20%' \
        '£17.09' \
        '£14.24'
      )
    end

    expect(page).to have_no_content('Remove uplifts for all items')
  end

  context 'when claim has been assessed' do
    let(:claim) { create(:claim, state: 'granted') }

    it 'lets me view details instead of changing them' do
      visit nsm_claim_letters_and_calls_path(claim)
      click_on 'Letters'

      expect(page).to have_content(
        'Number of letters12' \
        'Item rate3.56' \
        'Uplift requested95%' \
        'Total claimed£83.30'
      )
    end
  end
end
