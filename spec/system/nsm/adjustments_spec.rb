require 'rails_helper'

RSpec.describe 'Adjustments', :stub_oauth_token do
  let(:user) { create(:caseworker) }
  let(:claim) { build(:claim, data:) }
  let(:data) { build(:nsm_data, :with_adjustments) }

  before do
    stub_app_store_interactions(claim)
    sign_in user
    claim.assigned_user_id = user.id
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
            .and have_content('£144.42')
            .and have_content('Delete')
        end
      end

      it 'delete confirmed' do
        visit adjusted_nsm_claim_work_items_path(claim)
        click_on 'Delete'
        click_on 'Yes, delete it'
        expect(page).to have_content('This claim has no adjusted work items')
      end

      context 'there are no adjustments' do
        let(:data) { build(:nsm_data) }

        it 'raises error when trying to delete a non existent adjustment' do
          work_item_id = claim.data['work_items'][0]['id']
          expect do
            visit confirm_deletion_nsm_claim_work_item_path(claim, work_item_id)
          end.to raise_error 'Cannot delete non-existent adjustment'
        end
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
            .and have_content('£19.63')
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

      context 'there are no adjustments' do
        let(:data) { build(:nsm_data) }

        it 'raises error when trying to delete a non existent letters adjustment' do
          expect do
            visit confirm_deletion_nsm_claim_letters_and_call_path(claim_id: claim.id, id: 'letters')
          end.to raise_error 'Cannot delete non-existent adjustment'
        end

        it 'raises error when trying to delete a non existent calls adjustment' do
          expect do
            visit confirm_deletion_nsm_claim_letters_and_call_path(claim_id: claim.id, id: 'calls')
          end.to raise_error 'Cannot delete non-existent adjustment'
        end
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
          expect(page).to have_content('Accountants')
            .and have_content('Delete')
            .and have_content('adjusted up')
        end
      end

      it 'delete confirmed' do
        visit adjusted_nsm_claim_disbursements_path(claim)
        click_on 'Delete'
        click_on 'Yes, delete it'
        expect(page).to have_content('Adjusted costs')
        expect(page).to have_content('This claim has no adjusted disbursements')
      end

      context 'there are no adjustments' do
        let(:data) { build(:nsm_data) }

        it 'raises error when trying to delete a non existent adjustment' do
          disbursement_id = claim.data['disbursements'][0]['id']
          expect do
            visit confirm_deletion_nsm_claim_disbursement_path(claim, disbursement_id)
          end.to raise_error 'Cannot delete non-existent adjustment'
        end
      end
    end

    describe 'redirect to claim if all adjustments deleted' do
      it 'redirects' do
        visit adjusted_nsm_claim_work_items_path(claim)
        click_on 'Delete'
        click_on 'Yes, delete it'
        expect(page).to have_content('This claim has no adjusted work items')

        visit adjusted_nsm_claim_disbursements_path(claim)
        click_on 'Delete'
        click_on 'Yes, delete it'
        expect(page).to have_content('This claim has no adjusted disbursements')

        visit adjusted_nsm_claim_letters_and_calls_path(claim)
        within('.govuk-table__body') do
          click_link('Delete', match: :first)
        end
        click_on 'Yes, delete it'

        expect(page).to have_content('Adjusted costs')

        within('.govuk-table__body') do
          click_link('Delete', match: :first)
        end
        click_on 'Yes, delete it'
        expect(page).to have_content('You deleted the adjustment')
        expect(page).to have_content('Review and adjust')
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
        expect(page).to have_content('Review and adjust')
      end
    end
  end
end
