require 'rails_helper'

RSpec.describe 'Disbursements' do
  let(:user) { create(:caseworker) }
  let(:claim) { create(:claim) }
  let(:disbursement_form_error_message) do
    'activemodel.errors.models.non_standard_magistrates_payment/disbursements_form.attributes'
  end

  before { sign_in user }

  it 'can refuse disbursement item' do
    visit non_standard_magistrates_payment_claim_disbursements_path(claim)
    within('.govuk-table__row', text: 'Apples') do
      expect(page).to have_content(
        'Apples' \
        '£100.00' \
        '0%' \
        'Change'
      )
    end
    click_on 'Change'
    choose 'Yes'
    fill_in 'Explain your decision', with: 'Testing'
    click_on 'Save changes'

    visit non_standard_magistrates_payment_claim_disbursements_path(claim)

    within('.govuk-table__row', text: 'Apples') do
      expect(page).to have_content(
        'Apples' \
        '£100.00' \
        '0%' \
        '£0.00' \
        'Change'
      )
    end
    expect(page).to have_css('.govuk-heading-l', text: '£0.00')
  end

  it 'shows error if no changes made to an item' do
    visit non_standard_magistrates_payment_claim_disbursements_path(claim)
    within('.govuk-table__row', text: 'Apples') do
      expect(page).to have_content(
        'Apples' \
        '£100.00' \
        '0%' \
        'Change'
      )
    end
    click_on 'Change'
    choose 'No'
    click_on 'Save changes'
    expect(page).to have_css('.govuk-error-summary__body',
                             text: I18n.t("#{disbursement_form_error_message}.base.no_change"))
  end
end
