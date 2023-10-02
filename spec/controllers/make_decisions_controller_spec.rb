require 'rails_helper'

RSpec.describe MakeDecisionsController do
  context 'edit' do
    let(:claim) { instance_double(Claim, id: claim_id) }
    let(:claim_id) { SecureRandom.uuid }
    let(:decision) { instance_double(MakeDecisionForm) }

    before do
      allow(Claim).to receive(:find).and_return(claim)
      allow(MakeDecisionForm).to receive(:new).and_return(decision)
    end

    it 'renders successfully with claims' do
      allow(controller).to receive(:render)
      get :edit, params: { claim_id: }

      expect(controller).to have_received(:render)
                        .with(locals: { claim:, decision: })
      expect(response).to be_successful
    end
  end

  context 'update' do
    let(:decision) { instance_double(MakeDecisionForm, save:) }
    let(:user) { instance_double(User) }
    let(:claim) { instance_double(Claim, id: SecureRandom.uuid) }
    let(:save) { true }

    before do
      allow(User).to receive(:first_or_create).and_return(user)
      allow(MakeDecisionForm).to receive(:new).and_return(decision)
      allow(Claim).to receive(:find).and_return(claim)
    end

    it 'builds a decision object' do
      put :update, params: {
        claim_id: claim.id,
        make_decision_form: { state: 'grant', partial_comment: nil, reject_comment: nil, id: claim.id }
      }
      expect(MakeDecisionForm).to have_received(:new).with(
        'state' => 'grant', 'partial_comment' => '', 'reject_comment' => '', 'id' => claim.id, 'current_user' => user
      )
    end

    context 'when decision is updated' do
      it 'redirects to claim page' do
        put :update, params: {
          claim_id: claim.id,
          make_decision_form: { state: 'grant', partial_comment: nil, reject_comment: nil, id: claim.id }
        }

        expect(response).to redirect_to(claims_path) #, flash: { success: 'claim success text' })

      end
    end

    context 'when decision has an erorr being updated' do
      let(:save) { false }

      it 're-renders the edit page' do
        allow(controller).to receive(:render)
        put :update, params: {
          claim_id: claim.id,
          make_decision_form: { state: 'grant', partial_comment: nil, reject_comment: nil, id: claim.id }
        }

        expect(controller).to have_received(:render)
                          .with(:edit, locals: { claim:, decision: })
      end
    end
  end
end
