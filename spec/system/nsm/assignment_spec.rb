require 'rails_helper'

RSpec.describe 'Assign claims', :stub_oauth_token do
  let(:caseworker) { create(:caseworker, first_name: 'Me', last_name: 'Myself') }
  let(:claims) { [claim] }
  let(:assignment_event_stub) { stub_request(:post, "https://appstore.example.com/v1/submissions/#{claim&.id}/events").to_return(status: 201) }

  let(:auto_assignment_stub) do
    stub_request(:post, 'https://appstore.example.com/v1/submissions/auto_assignments').to_return(
      status: status,
      body: claim_data.to_json
    )
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
        application: claim.data }
    end
  end

  before do
    assignment_event_stub
    auto_assignment_stub
    search_stub
    claims
    sign_in caseworker
  end

  context 'when automatically assigning claims' do
    before do
      visit your_nsm_claims_path
      click_on 'Assess next claim'
    end

    context 'when there is a claim' do
      let(:claim) { create(:claim) }

      it 'assigns the claim to me' do
        expect(claim.reload.assignments.first.user).to eq caseworker
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
          let(:unassignment_stub) do
            stub_request(:delete, "https://appstore.example.com/v1/submissions/#{claim.id}/assignment").to_return(status: 204)
          end

          before do
            unassignment_stub
            click_on 'Remove from list'
          end

          it 'lets me unassign the claim' do
            fill_in 'Explain your decision', with: 'Too busy'
            click_on 'Yes, remove from list'
            expect(page).to have_content 'Assigned to: Unassigned'
            expect(claim.reload.assignments).to be_empty
            expect(unassignment_stub).to have_been_requested
          end

          it 'requires me to enter a reason' do
            click_on 'Yes, remove from list'
            expect(page).to have_content 'Add an explanation for your decision'
          end

          it 'lets me cancel my decision' do
            click_on 'Cancel'
            expect(page).to have_current_path nsm_claim_claim_details_path(claim)
            expect(claim.reload.assignments.first.user).to eq caseworker
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

    context 'when there is no local claim' do
      let(:id) { SecureRandom.uuid }
      let(:claim) { build(:claim, id:) }

      let(:search_response) do
        { metadata: { total_results: 0 }, raw_data: [] }
      end

      it 'imports the claim to me' do
        imported_claim = Claim.find(id)
        expect(imported_claim.assignments.first.user).to eq caseworker
        expect(page).to have_current_path nsm_claim_claim_details_path(imported_claim)
      end
    end

    context 'when there are multiple claims' do
      let(:claims) { [new_claim, old_claim] }
      let(:claim) { old_claim }
      let(:old_claim) { create(:claim, laa_reference: 'LAA-AAAAA', created_at: 6.days.ago) }
      let(:new_claim) { create(:claim, laa_reference: 'LAA-BBBBB', created_at: 5.days.ago) }

      it 'assigns the one returned by the app store to me' do
        expect(page).to have_content 'LAA-AAAAA'
      end
    end
  end

  context 'when a claim is assigned to someone else' do
    let(:claim) { create(:claim, state: 'submitted') }
    let(:unassignment_stub) do
      stub_request(:delete, "https://appstore.example.com/v1/submissions/#{claim.id}/assignment").to_return(status: 204)
    end

    before do
      unassignment_stub
      create(:assignment, submission: claim)
    end

    it 'lets me unassign them' do
      visit nsm_claim_claim_details_path(claim)
      click_on 'Remove from list'
      fill_in 'Explain your decision', with: 'I want them gone'
      click_on 'Yes, remove from list'
      expect(page).to have_content 'Assigned to: Unassigned'
      expect(claim.reload.assignments).to be_empty
      expect(unassignment_stub).to have_been_requested
    end
  end

  context 'when manually assigning claims' do
    let(:claim) { create(:claim, state: 'submitted') }
    let(:assignment_stub) do
      stub_request(:post, "https://appstore.example.com/v1/submissions/#{claim.id}/assignment").to_return(status: 201)
    end

    it 'allows me to assign a claim to myself' do
      assignment_stub
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

      create(:assignment, submission: claim)

      fill_in 'Explain your decision', with: 'because I want to'
      click_on 'Yes, add to my list'
      expect(page).to have_content 'This application is already assigned to a caseworker'
    end
  end
end
