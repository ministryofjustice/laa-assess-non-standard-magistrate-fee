require 'rails_helper'

RSpec.describe 'Viewers', :stub_oauth_token do
  let(:viewer) { create(:viewer, first_name: 'Me', last_name: 'Myself') }
  let(:submissions) { [claim, application] }
  let(:claim) { nil }
  let(:application) { nil }
  let(:search_stub) do
    stub_request(:post, 'https://appstore.example.com/v1/submissions/searches').to_return(
      status: 201,
      body: { metadata: { total_results: 0 },
              raw_data: [] }.to_json
    )
  end

  before do
    stub_app_store_interactions(application)
    stub_app_store_interactions(claim)
    search_stub
    submissions
    sign_in viewer
  end

  context 'when viewing NSM' do
    let(:claim) { build(:claim, state: 'submitted') }

    context 'when there is an unassigned claim' do
      it 'does not let me auto-assign a claim to myself' do
        visit nsm_root_path
        expect(page).to have_no_content 'Assess next claim'
        expect(page).to have_no_content 'Your claims'
      end

      it 'does not let me manually assign a claim' do
        visit nsm_claim_claim_details_path(claim)
        expect(page).to have_no_content 'Add to my list'
      end
    end

    context 'when a claim is assigned to someone else' do
      before { claim.assigned_user_id = SecureRandom.uuid }

      it 'does not let me unassign them' do
        visit nsm_claim_claim_details_path(claim)
        expect(page).to have_no_content 'Remove from list'
      end
    end
  end

  context 'when viewing Prior Authority' do
    let(:application) { build(:prior_authority_application, state: 'submitted') }

    context 'when there is an unassigned application' do
      it 'does not let me auto-assign' do
        visit prior_authority_root_path
        expect(page).to have_no_content 'Assess next application'
        expect(page).to have_no_content 'Your applications'
      end

      it 'does not let me manually assign' do
        visit prior_authority_application_path(application)
        expect(page).to have_no_content 'Add to my list'
      end
    end

    context 'when there is an assigned application' do
      before { application.assigned_user_id = create(:caseworker).id }

      it 'does not let me remove assignments' do
        visit prior_authority_application_path(application)
        expect(page).to have_no_content 'Remove from list'
      end
    end
  end
end
