require 'rails_helper'

RSpec.describe 'Disbursements' do
  let(:user) { create(:caseworker) }
  let(:claim) { build(:claim) }
  let(:disbursement_form_error_message) do
    'activemodel.errors.models.nsm/disbursements_form.attributes'
  end

  before do
    allow(AppStoreService).to receive_messages(list: [[claim], 1], get: claim, adjust: nil)
    sign_in user
  end

  it 'can refuse disbursement item' do
    visit nsm_claim_disbursements_path(claim)
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
    expect(AppStoreService).to have_received(:adjust).with(
      claim,
      { change_detail_sets:          [{ change: -100.0,
           comment: 'Testing',
           field: 'total_cost_without_vat',
           from: 100.0,
           to: 0 }],
        linked_id: '1c0f36fd-fd39-498a-823b-0a3837454563',
        linked_type: 'disbursements',
        user_id: user.id }
    )
  end

  it 'shows error if no changes made to an item' do
    visit nsm_claim_disbursements_path(claim)
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

  context 'when claim has been assessed' do
    let(:claim) { build(:claim, state: 'granted') }

    it 'lets me view details instead of changing them' do
      visit nsm_claim_disbursements_path(claim)
      expect(page).to have_no_content 'Change'
      click_on 'View'
      expect(page).to have_content(
        'Date12 Dec 2022' \
        'Disbursement typeApples' \
        'Details of disbursementDetails' \
        'Prior authority grantedYes' \
        'Total£100.00'
      )
    end
  end
end
