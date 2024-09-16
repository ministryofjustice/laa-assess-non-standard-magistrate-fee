require 'rails_helper'

RSpec.describe 'Adjustments' do
  let(:user) { create(:caseworker) }
  let(:claim) { create(:claim, :with_adjustments) }

  before do
    sign_in user
    create(:assignment, submission: claim, user: user)
    visit '/'
    click_on 'Accept analytics cookies'
  end

  context 'delete' do
    describe 'work item adjustment' do
      it 'delete redirects to confirmation' do
        visit adjusted_nsm_claim_work_items_path(claim)
        click_on 'Delete'
        expect(page).to have_content('Are you sure you want to delete this adjustment?')
      end

      it 'delete canceled by user' do
        visit adjusted_nsm_claim_work_items_path(claim)
        click_on 'Delete'
        click_on 'No, do not delete it'

        expect(page).to have_content('Adjusted costs')
        within('.govuk-table') do
          expect(page).to have_content('Waiting')
            .and have_content('£125.58')
            .and have_content('Delete')
        end
      end

      it 'delete confirmed' do
        visit adjusted_nsm_claim_work_items_path(claim)
        click_on 'Delete'
        click_on 'Yes, delete it'
        expect(page).to have_content('You do not have any adjusted work items')
      end
    end

    describe 'letters and calls' do
      it 'delete redirects to confirmation' do
        visit adjusted_nsm_claim_letters_and_calls_path(claim)
        within('.govuk-table__body') do
          click_link('Delete', match: :first)
        end
        expect(page).to have_content('Are you sure you want to delete this adjustment?')
      end

      it 'delete canceled by user' do
        visit adjusted_nsm_claim_letters_and_calls_path(claim)
        within('.govuk-table__body') do
          click_link('Delete', match: :first)
        end
        click_on 'No, do not delete it'

        expect(page).to have_content('Adjusted costs')
        within('.govuk-table') do
          expect(page).to have_content('Letters')
            .and have_content('£83.30')
        end
      end

      it 'delete confirmed' do
        visit adjusted_nsm_claim_letters_and_calls_path(claim)
        within('.govuk-table__body') do
          click_link('Delete', match: :first)
        end
        click_on 'Yes, delete it'
        expect(page).to have_content('You deleted the adjustment')
      end
    end

    describe 'disbursements' do
      it 'delete redirects to confirmation' do
        visit adjusted_nsm_claim_work_items_path(claim)
        click_on 'Delete'
        expect(page).to have_content('Are you sure you want to delete this adjustment?')
      end

      it 'delete cancelled by user' do
        visit adjusted_nsm_claim_disbursements_path(claim)
        click_on 'Delete'
        click_on 'No, do not delete it'

        expect(page).to have_content('Adjusted costs')
        within('.govuk-table') do
          expect(page).to have_content('Apples')
            .and have_content('Delete')
            .and have_content('adjusted up')
        end
      end

      it 'delete confirmed' do
        visit adjusted_nsm_claim_disbursements_path(claim)
        click_on 'Delete'
        click_on 'Yes, delete it'
        expect(page).to have_content('Adjusted costs')
        expect(page).to have_content('You do not have any disbursements')
      end
    end

    describe 'delete all adjustments' do
      it 'asks to confirm delete all adjustments' do
        visit adjusted_nsm_claim_work_items_path(claim)
        click_on 'Delete all adjustments'

        expect(page).to have_content('Are you sure you want to delete all adjustments?')
      end

      it 'delete all adjustments cancelled' do
        visit adjusted_nsm_claim_work_items_path(claim)
        click_on 'Delete all adjustments'
        click_on 'No, do not delete all'

        expect(page).to have_content('Delete all adjustments')
      end

      it 'delete confirmed expects comment' do
        visit adjusted_nsm_claim_disbursements_path(claim)
        click_on 'Delete all adjustments'
        click_on 'Yes, delete all'
        expect(page).to have_content('There is a problem on this page')
      end

      it 'delete confirmed' do
        visit adjusted_nsm_claim_disbursements_path(claim)
        click_on 'Delete all adjustments'
        fill_in 'nsm-delete-adjustments-form-comment-field', with: 'Test Data'
        click_on 'Yes, delete all'
        expect(page).to have_content('Deleted all adjustments')
      end
    end
  end
end
