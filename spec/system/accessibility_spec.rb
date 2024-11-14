require 'rails_helper'

# These specs will not run unless the `INCLUDE_ACCESSIBILITY_SPECS` env var is set
RSpec.describe 'Accessibility', :accessibility, :stub_oauth_token do
  subject { page }

  before do
    stub_request(:post, 'https://appstore.example.com/v1/submissions/searches').to_return(
      status: 201,
      body: { metadata: { total_results: 0 }, raw_data: [] }.to_json
    )
    stub_app_store_interactions(claim)
    stub_app_store_interactions(application)
    driven_by(:headless_chrome)
    sign_in caseworker
  end

  let(:caseworker) { create(:caseworker) }
  let(:application) { build(:prior_authority_application) }
  let(:claim) { build(:claim) }
  let(:be_axe_clean_with_caveats) do
    # Ignoring known false positive around skip links, see: https://design-system.service.gov.uk/components/skip-link/#when-to-use-this-component
    # Ignoring known false positive around aria-expanded attributes on conditional reveal radios, see: https://github.com/alphagov/govuk-frontend/issues/979
    be_axe_clean.excluding('.govuk-skip-link')
                .skipping('aria-allowed-attr')
  end

  context 'when viewing claim-specific screens' do
    %i[nsm_claim_claim_details
       nsm_claim_supporting_evidences
       nsm_claim_history
       edit_nsm_claim_change_risk
       edit_nsm_claim_make_decision
       edit_nsm_claim_send_back
       edit_nsm_claim_unassignment
       edit_nsm_claim_letters_and_calls_uplift
       nsm_claim_letters_and_calls_uplift
       edit_nsm_claim_work_items_uplift
       edit_nsm_claim_work_items_uplift].each do |path|
      describe "#{path} screen" do
        before do
          claim.assigned_user_id = caseworker.id
          visit send(:"#{path}_path", claim)
        end

        it 'is accessible' do
          expect(page).to(be_axe_clean_with_caveats)
        end
      end
    end

    describe 'when dealing with letters and calls' do
      %i[nsm_claim_letters_and_calls
         edit_nsm_claim_letters_and_call
         edit_nsm_claim_letters_and_call].each do |path|
        describe "#{path} screen" do
          before { visit send(:"#{path}_path", claim, :letters) }

          it 'is accessible' do
            expect(page).to(be_axe_clean_with_caveats)
          end
        end
      end
    end

    describe 'when dealing with a specific work item' do
      let(:item_id) { claim.data.dig('work_items', 0, 'id') }

      %i[nsm_claim_work_item
         edit_nsm_claim_work_item].each do |path|
        describe "#{path} screen" do
          before { visit send(:"#{path}_path", claim, item_id) }

          it 'is accessible' do
            expect(page).to(be_axe_clean_with_caveats)
          end
        end
      end
    end

    describe 'when dealing with a specific disbursement' do
      let(:item_id) { claim.data.dig('disbursements', 0, 'id') }

      %i[nsm_claim_disbursement
         edit_nsm_claim_disbursement].each do |path|
        describe "#{path} screen" do
          before { visit send(:"#{path}_path", claim, item_id) }

          it 'is accessible' do
            expect(page).to(be_axe_clean_with_caveats)
          end
        end
      end
    end
  end

  context 'when viewing general screens' do
    %i[your_nsm_claims
       open_nsm_claims
       closed_nsm_claims
       about_feedback_index
       about_cookies
       your_prior_authority_applications].each do |path|
      describe "#{path} screen" do
        before { visit send(:"#{path}_path") }

        it 'is accessible' do
          expect(page).to(be_axe_clean_with_caveats)
        end
      end
    end
  end

  context 'when viewing application-specific screens' do
    %i[prior_authority_application
       prior_authority_application_adjustments].each do |path|
      describe "#{path} screen" do
        before do
          visit send(:"#{path}_path", application)
        end

        it 'is accessible' do
          expect(page).to(be_axe_clean_with_caveats)
        end
      end
    end
  end

  context 'when signed out' do
    before do
      visit root_path
      click_on 'Sign out'
    end

    describe 'root screen' do
      before { visit '/' }

      it 'is accessible' do
        expect(page).to(be_axe_clean_with_caveats)
      end
    end
  end
end
