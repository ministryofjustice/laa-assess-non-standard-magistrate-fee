require 'rails_helper'

RSpec.describe HistoriesController do
  context 'show' do
    let(:claim) { instance_double(Claim, id: claim_id, events: events) }
    let(:events) { double(history: history_events) }
    let(:history_events) { [instance_double(Event, id: SecureRandom.uuid)] }
    let(:claim_id) { SecureRandom.uuid }
    let(:claim_summary) { instance_double(V1::ClaimSummary) }

    before do
      allow(Claim).to receive(:find).and_return(claim)
      allow(BaseViewModel).to receive_messages(build: claim_summary)
    end

    it 'find and builds the required object' do
      get :show, params: { claim_id: }

      expect(Claim).to have_received(:find).with(claim_id)
      expect(BaseViewModel).to have_received(:build).with(:claim_summary, claim)
    end

    it 'renders successfully with claims' do
      allow(controller).to receive(:render)
      get :show, params: { claim_id: }

      expect(controller).to have_received(:render).with(locals: { claim:, claim_summary:, history_events: })
      expect(response).to be_successful
    end
  end
end
