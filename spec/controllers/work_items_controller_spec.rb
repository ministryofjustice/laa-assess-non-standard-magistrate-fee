require 'rails_helper'

RSpec.describe WorkItemsController do
  context 'index' do
    let(:claim) { instance_double(Claim, id: claim_id) }
    let(:claim_id) { SecureRandom.uuid }
    let(:work_items) { [instance_double(V1::WorkItem, completed_on: Time.zone.today)] }
    let(:travel_and_waiting) { instance_double(V1::TravelAndWaiting) }
    let(:grouped_work_items) { { Time.zone.today => work_items } }

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
        locals: { claim: claim, work_items: grouped_work_items, travel_and_waiting: travel_and_waiting }
      )
      expect(response).to be_successful
    end
  end

  context 'edit' do
    let(:claim) { instance_double(Claim, id: claim_id) }
    let(:claim_id) { SecureRandom.uuid }
    let(:waiting) { instance_double(V1::WorkItem, work_type: double(value: 'waiting')) }
    let(:travel) { instance_double(V1::WorkItem, work_type: double(value: 'travel')) }
    let(:work_items) { [waiting, travel] }
    before do
      allow(Claim).to receive(:find).and_return(claim)
      allow(BaseViewModel).to receive(:build).and_return(work_items)

    end

    context 'when URL is for Waiting' do
      let(:id) { 'waiting' }

      it 'renders sucessfully with claims' do
        allow(controller).to receive(:render)
        get :edit, params:  { claim_id: claim_id, id: id }

        expect(controller).to have_received(:render)
                          .with(locals: { claim: claim, item: waiting })
        expect(response).to be_successful
      end
    end

    context 'when URL is for Travel' do
      let(:id) { 'travel' }

      it 'renders sucessfully with claims' do
        allow(controller).to receive(:render)
        get :edit, params:  { claim_id: claim_id, id: id }

        expect(controller).to have_received(:render)
                          .with(locals: { claim: claim, item: travel })
        expect(response).to be_successful
      end
    end
  end
end
