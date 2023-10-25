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
      allow(BaseViewModel).to receive_messages(build: work_items)
      allow(BaseViewModel).to receive_messages(build: travel_and_waiting)
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
end
