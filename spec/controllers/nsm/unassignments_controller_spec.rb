require 'rails_helper'

RSpec.describe Nsm::UnassignmentsController do
  context 'edit' do
    let(:claim) { create(:claim, id: claim_id) }
    let(:claim_id) { SecureRandom.uuid }
    let(:unassignment) { instance_double(Nsm::UnassignmentForm) }
    let(:defendant_name) { 'Tracy Linklater' }

    before do
      allow(Claim).to receive(:find).and_return(claim)
      allow(Nsm::UnassignmentForm).to receive(:new).and_return(unassignment)
    end

    it 'redirects to the claim details page' do
      get :edit, params: { claim_id: }
      expect(response).to redirect_to(nsm_claim_claim_details_path(claim))
    end

    context 'when the claim has an assignment' do
      before { create(:assignment, submission: claim) }

      it 'renders successfully with claims' do
        allow(controller).to receive(:render)
        get :edit, params: { claim_id: }

        expect(controller).to have_received(:render)
                          .with(locals: { claim:, unassignment: })
        expect(response).to be_successful
      end
    end
  end

  context 'update' do
    let(:unassignment) do
      instance_double(Nsm::UnassignmentForm, save:, unassignment_user:, user:)
    end
    let(:unassignment_user) { 'other' }
    let(:user) { instance_double(User, display_name: 'Jim Bob') }
    let(:claim) { create(:claim, :with_assignment) }
    let(:laa_reference_class) do
      instance_double(Nsm::V1::LaaReference, laa_reference: 'AAA111')
    end
    let(:defendant_name) { 'Tracy Linklater' }
    let(:save) { true }

    before do
      allow(User).to receive(:first_or_create).and_return(user)
      allow(Nsm::UnassignmentForm).to receive(:new).and_return(unassignment)
      allow(BaseViewModel).to receive(:build).and_return(laa_reference_class)
      allow(Claim).to receive(:find).and_return(claim)
    end

    it 'builds a decision object' do
      put :update, params: {
        claim_id: claim.id,
        nsm_unassignment_form: { comment: 'some commment' }
      }
      expect(Nsm::UnassignmentForm).to have_received(:new).with(
        'comment' => 'some commment', :claim => claim, 'current_user' => user
      )
    end

    context 'when decision is updated' do
      it 'redirects to claim page' do
        put :update, params: {
          claim_id: claim.id,
          nsm_unassignment_form: { comment: nil, id: claim.id }
        }

        expect(response).to redirect_to(nsm_claim_claim_details_path(claim))
      end

      context 'when current_user is the assigned user' do
        let(:unassignment_user) { 'assigned' }

        it 'redirects to claim page' do
          put :update, params: {
            claim_id: claim.id,
            nsm_unassignment_form: { state: 'further_info', comment: nil, id: claim.id }
          }

          expect(response).to redirect_to(nsm_claim_claim_details_path(claim))
        end
      end
    end

    context 'when decision has an erorr being updated' do
      let(:save) { false }

      it 're-renders the edit page' do
        allow(controller).to receive(:render)
        put :update, params: {
          claim_id: claim.id,
          nsm_unassignment_form: { comment: nil, id: claim.id }
        }

        expect(controller).to have_received(:render)
                          .with(:edit, locals: { claim:, unassignment: })
      end
    end
  end
end
