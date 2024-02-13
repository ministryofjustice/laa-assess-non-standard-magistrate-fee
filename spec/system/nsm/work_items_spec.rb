require 'rails_helper'

RSpec.describe 'Work items' do
  let(:user) { create(:caseworker) }
  let(:claim) { build(:claim) }

  before do
    allow(AppStoreService).to receive_messages(list: [[claim], 1], get: claim, adjust: nil)
    sign_in user
    visit '/'
    click_on 'Accept analytics cookies'
  end

  it 'can adjust a work item record' do
    visit nsm_claim_work_items_path(claim)

    within('.govuk-table__row', text: 'Waiting') do
      expect(page).to have_content(
        'Waiting' \
        '95%' \
        '2 Hours41 Minutes' \
        'Change'
      )
      click_on 'Change'
    end

    choose 'Yes, remove uplift'
    fill_in 'Hours', with: '10'
    fill_in 'Minutes', with: '59'
    fill_in 'Explain your decision', with: 'Testing'

    click_on 'Save changes'

    expect(AppStoreService).to have_received(:adjust).with(
      claim,
      { change_detail_sets:         [{ change: 498,
          comment: 'Testing',
          field: 'time_spent',
          from: 161,
          to: 659 },
                                     { change: -95, comment: 'Testing', field: 'uplift', from: 95, to: 0 }],
       linked_id: 'cf5e303e-98dd-4b0f-97ea-3560c4c5f137',
       linked_type: 'work_items',
       user_id: user.id }
    )
  end

  it 'can remove all uplift' do
    visit nsm_claim_work_items_path(claim)

    click_on 'Remove uplifts for all items'

    fill_in 'Explain your decision', with: 'Testing'

    click_on 'Yes, remove all uplift'

    expect(AppStoreService).to have_received(:adjust).exactly(1).time
  end

  context 'when claim has been assessed' do
    let(:claim) { build(:claim, state: 'granted') }

    it 'lets me view details instead of changing them' do
      visit nsm_claim_work_items_path(claim)
      expect(page).to have_no_content 'Change'
      click_on 'View'
      expect(page).to have_content(
        'Waiting' \
        'Date12 December 2022' \
        'Time spent2 Hrs 41 Mins' \
        'Fee earner initialsaaa' \
        'Uplift claimed95%' \
        'Claim cost£125.58'
      )
    end
  end
end
