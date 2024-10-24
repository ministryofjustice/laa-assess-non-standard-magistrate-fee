require 'rails_helper'

RSpec.describe Nsm::DisbursementsController do
  let(:claim) { create :claim, data: { disbursements: [disbursement], work_items: [] } }
  let(:user) { create :caseworker }
  let(:disbursement) { { id: SecureRandom.uuid } }

  before do
    allow(controller).to receive(:current_user).and_return(user)
    create :assignment, submission: claim, user: user
  end

  describe 'index' do
    it 'renders successfully' do
      get :index, params: { claim_id: claim.id }
      expect(response).to be_successful
    end
  end

  describe 'adjusted' do
    it 'renders successfully' do
      get :adjusted, params: { claim_id: claim.id }
      expect(response).to be_successful
    end
  end

  describe 'show' do
    it 'renders successfully' do
      get :show, params: { claim_id: claim.id, id: disbursement[:id] }
      expect(response).to be_successful
    end
  end

  describe 'edit' do
    it 'renders successfully' do
      get :edit, params: { claim_id: claim.id, id: disbursement[:id] }
      expect(response).to be_successful
    end
  end

  describe 'update' do
    let(:form) { instance_double(Nsm::DisbursementsForm, save:) }

    before do
      allow(Nsm::DisbursementsForm).to receive(:new).and_return(form)
      put :update,
          params: { claim_id: claim.id, id: disbursement[:id],
                    nsm_disbursements_form: { some: :data } }
    end

    context 'when form save is successful' do
      let(:save) { true }

      it 'redirects' do
        expect(controller).to redirect_to(
          nsm_claim_disbursements_path(claim)
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
