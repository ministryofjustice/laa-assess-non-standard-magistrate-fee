require 'rails_helper'

RSpec.describe 'Letters and Calls' do
  let(:user) { create(:caseworker) }
  let(:claim) { build(:claim) }

  before do
    allow(AppStoreService).to receive_messages(list: [[claim], 1], get: claim, adjust: nil)
    sign_in user
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
        '£83.30' \
        'Change'
      )
      click_on 'Change'
    end

    choose 'Yes, remove uplift'
    fill_in 'Change number of letters', with: '22'
    fill_in 'Explain your decision', with: 'Testing'

    click_on 'Save changes'

    expect(AppStoreService).to have_received(:adjust).with(
      claim,
      { change_detail_sets:         [{ change: 10, comment: 'Testing', field: 'count', from: 12, to: 22 },
                                     { change: -95, comment: 'Testing', field: 'uplift', from: 95, to: 0 }],
       linked_id: 'letters',
       linked_type: 'letters_and_calls',
       user_id: user.id }
    )
  end

  it 'can adjust a call record' do
    visit nsm_claim_letters_and_calls_path(claim)

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

    expect(AppStoreService).to have_received(:adjust).with(
      claim,
      { change_detail_sets: [{ change: 18, comment: 'Testing', field: 'count', from: 4, to: 22 },
                             { change: -20, comment: 'Testing', field: 'uplift', from: 20, to: 0 }],
       linked_id: 'calls',
       linked_type: 'letters_and_calls',
       user_id: user.id }
    )
  end

  it 'can remove all uplift' do
    visit nsm_claim_letters_and_calls_path(claim)

    click_on 'Remove uplifts for all items'

    fill_in 'Explain your decision', with: 'Testing'
    click_on 'Yes, remove all uplift'

    expect(AppStoreService).to have_received(:adjust).exactly(2).times
  end

  context 'when claim has been assessed' do
    let(:claim) { build(:claim, state: 'granted') }

    it 'lets me view details instead of changing them' do
      visit nsm_claim_letters_and_calls_path(claim)
      expect(page).to have_no_content 'Change'
      within('.govuk-table__body .govuk-table__row', match: :first) do
        click_on 'View'
      end
      expect(page).to have_content(
        'Number of letters12' \
        'Item rate3.56' \
        'Uplift requested95%' \
        'Total claimed£83.30'
      )
    end
  end
end
