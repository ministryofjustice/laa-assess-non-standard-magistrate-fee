require 'rails_helper'

RSpec.describe 'Assign claims', :stub_oauth_token do
  let(:caseworker) { create(:caseworker, first_name: 'Me', last_name: 'Myself') }
  let(:claims) { [claim] }

  let(:auto_assignment_stub) do
    stub_request(:post, 'https://appstore.example.com/v1/submissions/auto_assignments').to_return(lambda do |request|
      claim.assigned_user_id = JSON.parse(request.body)['current_user_id'] if claim
      {
        status: status,
        body: claim_data.to_json,
      }
    end)
  end

  let(:status) { 201 }

  let(:search_stub) do
    stub_request(:post, 'https://appstore.example.com/v1/submissions/searches').to_return(
      status: 201,
      body: search_response.to_json
    )
  end

  let(:search_response) do
    { metadata: { total_results: (claim ? 1 : 0) },
      raw_data: [claim_data].compact }
  end

  let(:claim_data) do
    if claim
      { application_id: claim.id,
        assigned_user_id: caseworker.id,
        application_type: 'crm7',
        application_risk: 'medium',
        application_state: 'submitted',
        json_schema_version: 1,
        version: 1,
        application: claim.data,
        last_updated_at: 1.day.ago }
    end
  end

  before do
    auto_assignment_stub
    search_stub
    claims
    sign_in caseworker
  end

  context 'when automatically assigning claims' do
    before do
      stub_app_store_interactions(claim)
      visit your_nsm_claims_path
      click_on 'Assess next claim'
    end

    context 'when there is a claim' do
      let(:claim) { build(:claim) }

      it 'assigns the claim to me' do
        expect(claim.assigned_user_id).to eq caseworker.id
        expect(page).to have_current_path nsm_claim_claim_details_path(claim)
      end

      it 'used the app store' do
        expect(auto_assignment_stub).to have_been_requested
      end

      context 'when the claim is already assigned to me' do
        it 'shows the claim in the Your Claims screen' do
          visit your_nsm_claims_path
          expect(page).to have_content claim.data['laa_reference']
        end

        context 'when I try to unassign the claim' do
          before do
            click_on 'Remove from list'
          end

          it 'lets me unassign the claim' do
            fill_in 'Explain your decision', with: 'Too busy'
            click_on 'Yes, remove from list'
            expect(page).to have_content 'Assigned to: Unassigned'
            expect(claim.assigned_user_id).to be_nil
          end

          it 'requires me to enter a reason' do
            click_on 'Yes, remove from list'
            expect(page).to have_content 'Add an explanation for your decision'
          end

          it 'lets me cancel my decision' do
            click_on 'Cancel'
            expect(page).to have_current_path nsm_claim_claim_details_path(claim)
            expect(claim.assigned_user_id).to eq caseworker.id
          end
        end
      end
    end

    context 'when there is no claim' do
      let(:claim) { nil }
      let(:status) { 404 }

      it 'shows me an explanation' do
        expect(page).to have_content 'There are no claims waiting to be allocated.'
      end
    end

    context 'when there are multiple claims' do
      let(:claims) { [new_claim, old_claim] }
      let(:claim) { old_claim }
      let(:old_claim) { build(:claim, laa_reference: 'LAA-AAAAA', created_at: 6.days.ago) }
      let(:new_claim) { build(:claim, laa_reference: 'LAA-BBBBB', created_at: 5.days.ago) }

      it 'assigns the one returned by the app store to me' do
        expect(page).to have_content 'LAA-AAAAA'
      end
    end
  end

  context 'when a claim is assigned to someone else' do
    let(:claim) { build(:claim, state: 'submitted') }

    before do
      stub_app_store_interactions(claim)
      claim.assigned_user_id = create(:caseworker).id
    end

    it 'lets me unassign them' do
      visit nsm_claim_claim_details_path(claim)
      click_on 'Remove from list'
      fill_in 'Explain your decision', with: 'I want them gone'
      click_on 'Yes, remove from list'
      expect(page).to have_content 'Assigned to: Unassigned'
      expect(claim.assigned_user_id).to be_nil
    end
  end

  context 'when manually assigning claims' do
    let(:claim) { build(:claim, state: 'submitted') }

    before { stub_app_store_interactions(claim) }

    it 'allows me to assign a claim to myself' do
      visit nsm_claim_claim_details_path(claim)
      click_on 'Add to my list'
      fill_in 'Explain your decision', with: 'because I want to'
      click_on 'Yes, add to my list'
      expect(page).to have_content 'In progress'
      expect(page).to have_content 'Assigned to: Me Myself'
    end

    it 'validates' do
      visit nsm_claim_claim_details_path(claim)
      click_on 'Add to my list'
      click_on 'Yes, add to my list'
      expect(page).to have_content 'Enter an explanation'
    end

    it 'checks that claim is not already assigned' do
      visit nsm_claim_claim_details_path(claim)
      click_on 'Add to my list'

      claim.assigned_user_id = SecureRandom.uuid

      fill_in 'Explain your decision', with: 'because I want to'
      click_on 'Yes, add to my list'
      expect(page).to have_content 'You are not authorised to perform this action'
    end
  end
end
