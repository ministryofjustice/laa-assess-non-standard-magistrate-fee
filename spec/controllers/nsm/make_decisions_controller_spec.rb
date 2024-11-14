require 'rails_helper'

RSpec.describe Nsm::MakeDecisionsController do
  let(:claim) { build :claim, assigned_user_id: user.id }
  let(:user) { create :caseworker }

  before do
    allow(Claim).to receive(:load_from_app_store).and_return(claim)
    allow(controller).to receive(:current_user).and_return(user)
  end

  describe 'edit' do
    it 'renders successfully' do
      get :edit, params: { claim_id: claim.id }
      expect(response).to be_successful
    end
  end

  describe 'update' do
    let(:form) { instance_double(Nsm::MakeDecisionForm, save: save, state: 'granted') }

    before do
      allow(Nsm::MakeDecisionForm).to receive(:new).and_return(form)
      put :update,
          params: { claim_id: claim.id,
                    nsm_make_decision_form: { some: :data } }
    end

    context 'when form save is successful' do
      let(:save) { true }

      it 'redirects' do
        expect(controller).to redirect_to(
          closed_nsm_claims_path
        )
      end
    end

    context 'when form save is unsuccessful' do
      let(:save) { false }

      it 'renders rather than redirects' do
        expect(response).to be_successful
      end
    end
  end
end
