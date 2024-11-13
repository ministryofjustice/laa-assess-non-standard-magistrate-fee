require 'rails_helper'

RSpec.describe Nsm::WorkItemsController do
  let(:claim) { create :claim, data: { work_items: [work_item] } }
  let(:user) { create :caseworker }
  let(:work_item) { { id: SecureRandom.uuid, work_type: 'travel' } }

  before do
    allow(Claim).to receive(:load_from_app_store).and_return(claim)
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
      get :show, params: { claim_id: claim.id, id: work_item[:id] }
      expect(response).to be_successful
    end
  end

  describe 'edit' do
    it 'renders successfully' do
      get :edit, params: { claim_id: claim.id, id: work_item[:id] }
      expect(response).to be_successful
    end
  end

  describe 'update' do
    let(:form) { instance_double(Nsm::WorkItemForm, save!: save) }

    before do
      allow(Nsm::WorkItemForm).to receive(:new).and_return(form)
      put :update,
          params: { claim_id: claim.id, id: work_item[:id],
                    nsm_work_item_form: { some: :data } }
    end

    context 'when form save is successful' do
      let(:save) { true }

      it 'redirects' do
        expect(controller).to redirect_to(
          nsm_claim_work_items_path(claim)
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
