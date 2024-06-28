require 'rails_helper'

RSpec.describe 'Work items' do
  let(:user) { create(:caseworker) }
  let(:claim) { create(:claim) }

  before do
    sign_in user
    create(:assignment, submission: claim, user: user)
    visit '/'
    click_on 'Accept analytics cookies'
  end

  it 'can adjust a work item record' do
    visit nsm_claim_work_items_path(claim)

    within('.data-table .govuk-table__row', text: 'Waiting') do
      expect(page).to have_content(
        '1 ' \
        'Waiting ' \
        '12 Dec 2022 ' \
        'aaa ' \
        '2 hours:41 minutes ' \
        '95% ' \
        '£125.58'
      )
      click_on 'Waiting'
    end

    choose 'Yes, remove uplift'
    fill_in 'Hours', with: '10'
    fill_in 'Minutes', with: '59'
    fill_in 'Explain your decision', with: 'Testing'

    click_on 'Save changes'

    within('.data-table .govuk-table__row', text: 'Waiting') do
      expect(page).to have_content(
        '1 ' \
        'Waiting ' \
        '12 Dec 2022 ' \
        'aaa ' \
        '2 hours:41 minutes ' \
        '95% ' \
        '£125.58 ' \
        '£263.60'
      )
    end

    visit adjusted_nsm_claim_work_items_path(claim)

    within('.govuk-table__row', text: 'Waiting') do
      expect(page).to have_content(
        '1 ' \
        'Waiting ' \
        'Testing ' \
        '10 hours:59 minutes ' \
        '0% ' \
        '£263.60'
      )
    end
  end

  it 'can remove all uplift' do
    visit nsm_claim_work_items_path(claim)

    click_on 'Remove uplifts for all items'

    fill_in 'Explain your decision', with: 'Testing'

    click_on 'Yes, remove all uplift'

    within('.data-table .govuk-table__row', text: 'Waiting') do
      expect(page).to have_content(
        '1 ' \
        'Waiting ' \
        '12 Dec 2022 ' \
        'aaa ' \
        '2 hours:41 minutes ' \
        '95% ' \
        '£125.58 ' \
        '£64.40'
      )
    end

    expect(page).to have_no_content('Remove uplifts for all items')
  end

  context 'when claim has been assessed' do
    let(:claim) { create(:claim, state: 'granted') }

    it 'lets me view details instead of changing them' do
      visit nsm_claim_work_items_path(claim)

      within('.data-table') do
        click_on 'Waiting'
      end

      expect(page).to have_content(
        'Waiting' \
        'Date12 December 2022' \
        'Time spent2 hours 41 minutes' \
        'Fee earner initialsaaa' \
        'Uplift claimed95%' \
        'Claim cost£125.58'
      )
    end
  end

  context 'when there is an attendance without counsel work item' do
    let(:claim) do
      create(
        :claim,
        work_items: [
          {
            'id' => 'cf5e303e-98dd-4b0f-97ea-3560c4c5f137',
            'uplift' => 95,
            'pricing' => 24.0,
            'work_type' => {
              'en' => 'Attendance without counsel',
              'value' => 'attendance_without_counsel'
            },
            'fee_earner' => 'aaa',
            'time_spent' => 161,
            'completed_on' => '2022-12-12'
          }
        ]
      )
    end

    it 'does not change the work type if I ask it not to when making other adjustments' do
      visit nsm_claim_work_items_path(claim)

      within('.govuk-table__row', text: 'Attendance without counsel') do
        expect(page).to have_content('95%')
        click_on 'Change'
      end

      choose 'Yes, remove uplift'
      choose 'No, do not change it'
      fill_in 'Explain your decision', with: 'Testing'

      click_on 'Save changes'
      visit nsm_claim_work_items_path(claim)

      expect(page).to have_content('Attendance without counsel')
    end

    it 'changes the work type if I ask it to' do
      visit nsm_claim_work_items_path(claim)

      within('.govuk-table__row', text: 'Attendance without counsel') do
        click_on 'Change'
      end

      choose 'Yes, change it'
      fill_in 'Explain your decision', with: 'Testing'

      click_on 'Save changes'
      visit nsm_claim_work_items_path(claim)

      expect(page).to have_content('Attendance with counsel')

      page.find('.govuk-details__summary-text').click
      within('.govuk-details__text') do
        expect(page).to have_content('Attendance with counsel')
      end
    end

    it 'shows a validation error if I do not specify' do
      visit nsm_claim_work_items_path(claim)

      within('.govuk-table__row', text: 'Attendance without counsel') do
        click_on 'Change'
      end

      fill_in 'Explain your decision', with: 'Testing'

      click_on 'Save changes'
      expect(page).to have_content('Select yes if you want to change the work type to attendance with counsel assigned')
    end
  end
end
