require 'rails_helper'

RSpec.describe 'Disbursements', :stub_oauth_token do
  let(:user) { create(:caseworker) }
  let(:claim) { build(:claim) }
  let(:disbursement_form_error_message) do
    'activemodel.errors.models.nsm/disbursements_form.attributes'
  end

  before do
    stub_app_store_interactions(claim)
    claim.assigned_user_id = user.id
    sign_in user
  end

  it 'refuse disbursement item' do
    visit nsm_claim_disbursements_path(claim)
    within('.govuk-table__row', text: 'Accountants') do
      expect(page).to have_content(
        '1 ' \
        'Accountants ' \
        '12 Dec 2022 ' \
        '£100.00 ' \
        '£0.00 ' \
        '£100.00'
      )
    end
    click_on 'Accountants'
    fill_in 'Change disbursement cost', with: '0'
    fill_in 'Explain your decision', with: 'Testing'
    click_on 'Save changes'

    within('.govuk-table__row', text: 'Accountants') do
      expect(page).to have_content(
        '1 ' \
        'Accountants ' \
        '12 Dec 2022 ' \
        '£100.00 ' \
        '£0.00 ' \
        '£100.00 ' \
        '£0.00'
      )
    end

    visit adjusted_nsm_claim_disbursements_path(claim)

    within('.govuk-table__row', text: 'Accountants') do
      expect(page).to have_content(
        '1 ' \
        'Accountants ' \
        'Testing ' \
        '£0.00 ' \
        '£0.00 ' \
        '£0.00'
      )
    end
  end

  it 'shows error if no changes made to an item' do
    visit nsm_claim_disbursements_path(claim)
    within('.govuk-table__row', text: 'Accountants') do
      expect(page).to have_content(
        '1 ' \
        'Accountants ' \
        '12 Dec 2022 ' \
        '£100.00 ' \
        '£0.00 ' \
        '£100.00'
      )
    end
    click_on 'Accountants'
    fill_in 'Change disbursement cost', with: '100'
    click_on 'Save changes'
    expect(page).to have_css('.govuk-error-summary__body',
                             text: I18n.t("#{disbursement_form_error_message}.base.no_change"))
  end

  context 'when claim has been assessed' do
    let(:claim) { build(:claim, state: 'granted') }

    it 'lets me view details instead of changing them' do
      visit nsm_claim_disbursements_path(claim)
      within('main') { expect(page).to have_no_content 'Change' }
      click_on 'Accountants'
      expect(page).to have_content(
        'Date12 December 2022' \
        'Disbursement typeAccountants' \
        'Details of disbursementDetails' \
        'Prior authority grantedYes' \
        'VAT claimed20%' \
        'Total cost claimed£100.00'
      )
    end
  end
end
