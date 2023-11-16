require 'rails_helper'

RSpec.describe WorkItemsController do
  context 'index' do
    let(:claim) { instance_double(Claim, id: claim_id) }
    let(:claim_id) { SecureRandom.uuid }
    let(:work_items) { [instance_double(V1::WorkItem, completed_on: Time.zone.today)] }
    let(:travel_and_waiting) { instance_double(V1::TravelAndWaiting) }

    before do
      allow(Claim).to receive(:find).and_return(claim)
      allow(BaseViewModel).to receive(:build).with(:work_item, anything, anything).and_return(work_items)
      allow(BaseViewModel).to receive(:build).with(:travel_and_waiting, anything).and_return(travel_and_waiting)
    end

    it 'find and builds the required object' do
      get :index, params: { claim_id: }

      expect(Claim).to have_received(:find).with(claim_id)
      expect(BaseViewModel).to have_received(:build).with(:work_item, claim, 'work_items')
      expect(BaseViewModel).to have_received(:build).with(:travel_and_waiting, claim)
    end

    it 'renders successfully with claims' do
      allow(controller).to receive(:render)
      get :index, params: { claim_id: }

      expect(controller).to have_received(:render).with(
        locals: { claim:, work_items:, travel_and_waiting: }
      )
      expect(response).to be_successful
    end
  end

  context 'edit' do
    let(:claim) { instance_double(Claim, id: claim_id) }
    let(:claim_id) { SecureRandom.uuid }
    let(:travel_id) { SecureRandom.uuid }
    let(:waiting_id) { SecureRandom.uuid }
    let(:waiting) do
      instance_double(V1::WorkItem, id: waiting_id, work_type: double(value: 'waiting'), form_attributes: {})
    end
    let(:travel) do
      instance_double(V1::WorkItem, id: travel_id, work_type: double(value: 'travel'), form_attributes: {})
    end
    let(:work_items) { [waiting, travel] }
    let(:form) { instance_double(WorkItemForm) }

    before do
      allow(Claim).to receive(:find).and_return(claim)
      allow(BaseViewModel).to receive(:build).and_return(work_items)
      allow(WorkItemForm).to receive(:new).and_return(form)
    end

    it 'renders sucessfully with claims' do
      allow(controller).to receive(:render)
      get :edit, params: { claim_id: claim_id, id: waiting_id, form: form }

      expect(controller).to have_received(:render)
                        .with(locals: { claim: claim, item: waiting, form: form })
      expect(response).to be_successful
    end
  end


  context 'show' do
    let(:claim) { instance_double(Claim, id: claim_id) }
    let(:claim_id) { SecureRandom.uuid }
    let(:travel_id) { SecureRandom.uuid }
    let(:waiting_id) { SecureRandom.uuid }
    let(:waiting) do
      instance_double(V1::WorkItem, id: waiting_id, work_type: double(value: 'waiting'), form_attributes: {})
    end
    let(:travel) do
      instance_double(V1::WorkItem, id: travel_id, work_type: double(value: 'travel'), form_attributes: {})
    end
    let(:work_items) { [waiting, travel] }

    before do
      allow(Claim).to receive(:find).and_return(claim)
      allow(BaseViewModel).to receive(:build).and_return(work_items)
    end

    it 'renders sucessfully with claims' do
      allow(controller).to receive(:render)
      get :show, params: { claim_id: claim_id, id: waiting_id }

      expect(controller).to have_received(:render)
                        .with(locals: { claim: claim, item: waiting })
      expect(response).to be_successful
    end
  end

  context 'update' do
    let(:claim) { instance_double(Claim, id: claim_id) }
    let(:claim_id) { SecureRandom.uuid }
    let(:waiting_id) { SecureRandom.uuid }
    let(:travel_id) { SecureRandom.uuid }
    let(:waiting) do
      instance_double(V1::WorkItem, id: waiting_id, work_type: double(value: 'waiting'), form_attributes: {})
    end
    let(:travel) do
      instance_double(V1::WorkItem, id: travel_id, work_type: double(value: 'travel'), form_attributes: {})
    end
    let(:work_items) { [waiting, travel] }
    let(:form) { instance_double(WorkItemForm, save:) }

    before do
      allow(Claim).to receive(:find).and_return(claim)
      allow(BaseViewModel).to receive(:build).and_return(work_items)
      allow(WorkItemForm).to receive(:new).and_return(form)
    end

    context 'when form save is successful' do
      let(:save) { true }

      it 'renders sucessfully with claims' do
        allow(controller).to receive(:render)
        get :update, params: { claim_id: claim_id, id: waiting_id, work_item_form: { some: :data } }

        expect(controller).to redirect_to(claim_adjustments_path(claim, anchor: 'work-items-tab'))
        expect(response).to have_http_status(:found)
      end
    end

    context 'when form save is unsuccessful' do
      let(:save) { false }

      it 'renders successfully with claims' do
        allow(controller).to receive(:render)
        put :update, params: { claim_id: claim_id, id: waiting_id, work_item_form: { some: :data } }

        expect(controller).to have_received(:render)
                          .with(:edit, locals: { claim: claim, form: form, item: waiting })
        expect(response).to be_successful
      end
    end
  end
end
