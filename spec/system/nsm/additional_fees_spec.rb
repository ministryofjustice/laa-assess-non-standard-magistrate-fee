require 'rails_helper'

RSpec.describe 'Additional Fees', :stub_oauth_token do
  let(:user) { create(:caseworker) }
  let(:youth_court) { 'yes' }
  let(:claim_type) { 'non_standard_magistrate' }
  let(:include_youth_court_fee_original) { nil }
  let(:include_youth_court_fee) { false }
  let(:plea_category) { 'category_1a' }
  let(:rep_order_date) { Date.new(2024, 12, 6) }
  let(:state) { 'granted' }
  let(:claim) { build(:claim, data:) }
  let(:data) do
    build(
      :nsm_data, youth_court:, claim_type:, plea_category:, rep_order_date:,
      include_youth_court_fee:, include_youth_court_fee_original:
    )
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

    it 'lets me view details instead of changing them' do
      visit nsm_claim_additional_fees_path(claim)
      click_on 'Youth court fee'

      expect(page).to have_content(
        'Youth court fee Net cost claimed £0.00'
      )
    end
  end

  context 'when a claim has an additional fee' do
    let(:include_youth_court_fee) { true }

    it 'shows the additional fee and what is allowed' do
      visit nsm_claim_additional_fees_path(claim)
      click_on 'Youth court fee'

      expect(page).to have_content(
        'Youth court fee Net cost claimed £598.59'
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

  context 'youth court fee included' do
    let(:include_youth_court_fee) { true }
    let(:state) { 'in_progress' }

    it 'review and adjust page shows additional fees tab' do
      visit nsm_claim_work_items_path(claim)

      expect(page).to have_content(
        'Additional fees'
      )
    end

    it 'Additional fees tab shows link to net allowed/net claimed' do
      visit nsm_claim_work_items_path(claim)

      click_on 'Additional fees'

      within('.govuk-tabs__panel') do
        within('.govuk-table__body') do
          expect(page).to have_content('Youth court fee£598.59')
        end
      end
    end

    it 'Youth court fee link allows adjustment' do
      visit nsm_claim_additional_fees_path(claim)

      click_on 'Youth court fee'

      expect(page).to have_content('Adjust additional fee')
    end

    it 'allows removal adjustment of youth court fee' do
      visit nsm_claim_additional_fees_path(claim)

      within('.govuk-tabs__panel') do
        click_on 'Youth court fee'
      end

      expect(page).to have_content('Adjust additional fee')

      choose 'Yes, remove fee'
      fill_in 'nsm-youth-court-fee-form-explanation-field', with: 'Because I can'

      click_button 'Save changes'

      within('.govuk-tabs__panel') do
        within('.govuk-table__body') do
          expect(page).to have_content('Youth court fee£598.59£0.00')
        end
      end
    end

    it 'shows error message if no explanation given' do
      visit nsm_claim_additional_fees_path(claim)
      within('.govuk-tabs__panel') do
        click_on 'Youth court fee'
      end

      choose 'Yes, remove fee'

      click_button 'Save changes'

      expect(page).to have_content('Enter a reason for the adjustment')
    end

    context 'Caseworker removes fee' do
      let(:claim) do
        build(:claim, state: 'in_progress').tap do |claim|
          claim.data.merge!(data).merge!({ rep_order_date: Date.new(2024, 12, 6),
                                           include_youth_court_fee: false,
                                           include_youth_court_fee_original: true,
                                           youth_court_fee_adjustment_comment: 'Because I can' })
        end
      end

      it 'allows restoration adjustment of youth court fee' do
        visit nsm_claim_additional_fees_path(claim)

        within('.govuk-tabs__panel') do
          click_on 'Youth court fee'
        end

        expect(page).to have_content('Adjust additional fee')

        choose 'No, do not remove fee'

        click_button 'Save changes'

        within('.govuk-tabs__panel') do
          within('.govuk-table__body') do
            expect(page).not_to have_content('Youth court fee£598.59£0.00')
            expect(page).to have_content('Youth court fee£598.59')
          end
        end
      end

      it 'additonal fee shows in adjustments' do
        visit nsm_claim_work_items_path(claim)
        expect(page).to have_content('Adjustments')
        click_on 'Adjustments'
        expect(page).to have_content('Additional fees')
        click_on 'Additional fees'
        within('.govuk-tabs__panel') do
          click_on 'Youth court fee'
        end

        expect(page).to have_content('Adjust additional fee')
      end

      it 'removeing additional fee adjustment also removes adjustments tab if only adjustment' do
        visit nsm_claim_additional_fees_path(claim)
        within('.govuk-tabs__panel') do
          click_on 'Youth court fee'
        end
        expect(page).to have_content('Adjust additional fee')
        choose 'No, do not remove fee'
        click_button 'Save changes'
        expect(page).not_to have_content('Adjustments')
      end
    end
  end
end
