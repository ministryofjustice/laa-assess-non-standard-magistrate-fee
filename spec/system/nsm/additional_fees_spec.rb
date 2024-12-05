require 'rails_helper'

RSpec.describe 'Additional Fees', :stub_oauth_token do
  let(:user) { create(:caseworker) }
  let(:data) do
    { youth_court:, claim_type:, plea_category:, rep_order_date: }
  end
  let(:youth_court) { 'yes' }
  let(:claim_type) { 'non_standard_magistrate' }
  let(:plea_category) { 'category_1a' }
  let(:rep_order_date) { Date.new(2024, 12, 6) }
  let(:state) { 'granted' }
  let(:claim) do
    build(:claim, state:).tap do |claim|
      claim.data.merge!(data)
    end
  end

  before do
    allow(claim).to receive(:additional_fees).and_return(
      {
        youth_court_fee: { claimed_total_exc_vat: 598.59 },
        total: { claimed_total_exc_vat: 598.59 }
      }
    )

    stub_app_store_interactions(claim)
    sign_in user
    claim.assigned_user_id = user.id
    visit '/'
    click_on 'Accept analytics cookies'
  end

  context 'when claim is valid' do
    let(:state) { 'granted' }
    let(:youth_court) { 'yes' }

    it 'lets me view details instead of changing them' do
      visit nsm_claim_additional_fees_path(claim)
      click_on 'Youth court fee'

      expect(page).to have_content(
        'Youth court fee' \
        'Net cost claimed£0.00' \
      )
    end
  end

  context 'when claim cannot apply a youth court fee' do
    let(:rep_order_date) { Date.new(2024, 12, 5) }

    it 'does not let me view details' do
      visit nsm_claim_additional_fees_path(claim)

      expect(page).to have_content(
        'Page not found'
      )
    end
  end

  context 'rep order date is nil' do
    let(:rep_order_date) { nil }

    it 'does not let me view details' do
      visit nsm_claim_additional_fees_path(claim)

      expect(page).to have_content(
        'Page not found'
      )
    end
  end

  context 'rep order date is not a valid date' do
    let(:rep_order_date) { 'garbage' }

    it 'does not let me view details' do
      expect { visit nsm_claim_additional_fees_path(claim) }.to raise_error(Date::Error)
    end
  end
end
