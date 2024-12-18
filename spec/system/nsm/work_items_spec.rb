require 'rails_helper'

RSpec.describe 'Work items', :stub_oauth_token do
  let(:user) { create(:caseworker) }
  let(:claim) { build(:claim) }

  before do
    stub_app_store_interactions(claim)
    sign_in user
    claim.assigned_user_id = user.id
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
        '£144.42'
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
        '£144.42 ' \
        '£303.14'
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
        '£303.14'
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
        '£144.42 ' \
        '£74.06'
      )
    end

    expect(page).to have_no_content('Remove uplifts for all items')
  end

  context 'when claim has been assessed' do
    let(:claim) { build(:claim, state: 'granted') }

    it 'lets me view details instead of changing them' do
      visit nsm_claim_work_items_path(claim)

      within('.data-table') do
        click_on 'Waiting'
      end

      expect(page).to have_content(
        'Waiting' \
        'Date12 December 2022' \
        'Fee earner initialsaaa' \
        'Time claimed2 hours 41 minutes' \
        'Item rate£27.60' \
        'Uplift claimed95%' \
        'Net cost claimed£144.42'
      )
    end
  end

  context 'when there is an attendance without counsel work item' do
    let(:data) do
      build(
        :nsm_data,
        work_items: [
          {
            'id' => 'cf5e303e-98dd-4b0f-97ea-3560c4c5f137',
            'uplift' => 95,
            'pricing' => -1,
            'work_type' => 'attendance_without_counsel',
            'fee_earner' => 'aaa',
            'time_spent' => 161,
            'completed_on' => '2022-12-12'
          }
        ]
      )
    end
    let(:claim) { build(:claim, data:) }

    it 'does not change the work type if I ask it not to when making other adjustments' do
      visit nsm_claim_work_items_path(claim)

      within('.govuk-table__row', text: 'Attendance without counsel') do
        expect(page).to have_content('95%')
        click_on 'Attendance without counsel'
      end

      choose 'Yes, remove uplift'
      fill_in 'Explain your decision', with: 'Testing'

      click_on 'Save changes'
      visit nsm_claim_work_items_path(claim)

      expect(page).to have_content('Attendance without counsel')
    end

    it 'changes the work type and associated pricing if I ask it to' do
      visit nsm_claim_work_items_path(claim)
      expect(page).to have_content 'Sum of net cost claimed: £272.87'

      within('.govuk-table__row', text: 'Attendance without counsel') do
        click_on 'Attendance without counsel'
      end

      choose 'Attendance with counsel'
      fill_in 'Explain your decision', with: 'Testing'

      click_on 'Save changes'
      visit nsm_claim_work_items_path(claim)

      expect(page).to have_content('Attendance with counsel [1]')
                  .and have_content('Sum of net cost claimed: £272.87')
                  .and have_content('Sum of net cost allowed: £186.70')
                  .and have_content('This item was adjusted to be a different work item type')
      page.find('.govuk-details__summary-text').click
      within('.govuk-details__text') do
        expect(page).to have_content('Attendance without counsel [*]')
      end
    end
  end
end
