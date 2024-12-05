require 'rails_helper'

RSpec.describe 'Additional Fees', :stub_oauth_token do
  let(:user) { create(:caseworker) }
  let(:data) do
    { youth_court: 'yes', claim_type: 'non_standard_magistrate', plea_category: 'category_1a' }
  end
  let(:claim) do
    build(:claim).tap do |claim|
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
    let(:claim) do
      build(:claim, state: 'granted').tap do |claim|
        claim.data.merge!(data)
      end
    end

    it 'lets me view details instead of changing them' do
      visit nsm_claim_additional_fees_path(claim)
      click_on 'Youth court fee'

      expect(page).to have_content(
        'Youth court fee' \
        'Net cost claimed£0.00' \
      )
    end
  end

  context 'when claim is not valid' do
    let(:claim) do
      build(:claim, state: 'granted').tap do |claim|
        claim.data.merge!(data).merge!({ youth_court: 'no' })
      end
    end

    it 'lets me view details instead of changing them' do
      visit nsm_claim_additional_fees_path(claim)

      expect(page).to have_content(
        'Page not found'
      )
    end
  end
end
