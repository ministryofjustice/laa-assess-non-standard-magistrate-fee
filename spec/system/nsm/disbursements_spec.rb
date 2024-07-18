require 'rails_helper'

RSpec.describe 'Disbursements' do
  let(:user) { create(:caseworker) }
  let(:claim) { create(:claim) }
  let(:disbursement_form_error_message) do
    'activemodel.errors.models.nsm/disbursements_form.attributes'
  end

  before do
    create(:assignment, submission: claim, user: user)
    sign_in user
  end

  it 'refuse disbursement item' do
    visit nsm_claim_disbursements_path(claim)
    within('.govuk-table__row', text: 'Apples') do
      expect(page).to have_content(
        '1 ' \
        'Apples ' \
        '12 Dec 2022 ' \
        '£100.00 ' \
        '£0.00 ' \
        '£100.00'
      )
    end
    click_on 'Apples'
    fill_in 'Change disbursement cost', with: '0'
    fill_in 'Explain your decision', with: 'Testing'
    click_on 'Save changes'

    visit nsm_claim_disbursements_path(claim)

    within('.govuk-table__row', text: 'Apples') do
      expect(page).to have_content(
        '1 ' \
        'Apples ' \
        '12 Dec 2022 ' \
        '£100.00 ' \
        '£0.00 ' \
        '£100.00 ' \
        '£0.00'
      )
    end

    visit adjusted_nsm_claim_disbursements_path(claim)

    within('.govuk-table__row', text: 'Apples') do
      expect(page).to have_content(
        '1 ' \
        'Apples ' \
        'Testing ' \
        '£0.00 ' \
        '£0.00 ' \
        '£0.00'
      )
    end
  end

  it 'shows error if no changes made to an item' do
    visit nsm_claim_disbursements_path(claim)
    within('.govuk-table__row', text: 'Apples') do
      expect(page).to have_content(
        '1 ' \
        'Apples ' \
        '12 Dec 2022 ' \
        '£100.00 ' \
        '£0.00 ' \
        '£100.00'
      )
    end
    click_on 'Apples'
    fill_in 'Change disbursement cost', with: '100'
    click_on 'Save changes'
    expect(page).to have_css('.govuk-error-summary__body',
                             text: I18n.t("#{disbursement_form_error_message}.base.no_change"))
  end

  context 'when claim has been assessed' do
    let(:claim) { create(:claim, state: 'granted') }

    it 'lets me view details instead of changing them' do
      visit nsm_claim_disbursements_path(claim)
      within('main') { expect(page).to have_no_content 'Change' }
      click_on 'Apples'
      expect(page).to have_content(
        'Date12 Dec 2022' \
        'Disbursement typeApples' \
        'Details of disbursementDetails' \
        'Prior authority grantedYes' \
        'VAT20%' \
        'Total£100.00'
      )
    end
  end
end
