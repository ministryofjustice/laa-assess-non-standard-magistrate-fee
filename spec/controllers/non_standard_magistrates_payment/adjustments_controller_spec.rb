require 'rails_helper'

RSpec.describe NonStandardMagistratesPayment::AdjustmentsController do
  context 'show' do
    let(:claim) { instance_double(Claim, id: claim_id) }
    let(:claim_id) { SecureRandom.uuid }
    let(:claim_summary) { instance_double(V1::ClaimSummary) }
    let(:core_cost_summary) { instance_double(V1::CoreCostSummary) }

    before do
      allow(Claim).to receive(:find).and_return(claim)
      allow(BaseViewModel).to receive(:build).with(:claim_summary, claim).and_return(claim_summary)
      allow(BaseViewModel).to receive(:build).with(:core_cost_summary, claim).and_return(core_cost_summary)
    end

    it 'find and builds the required object' do
      get :show, params: { claim_id: }

      expect(Claim).to have_received(:find).with(claim_id)
      expect(BaseViewModel).to have_received(:build).with(:claim_summary, claim)
      expect(BaseViewModel).to have_received(:build).with(:core_cost_summary, claim)
    end

    it 'renders successfully with claims' do
      allow(controller).to receive(:render)
      get :show, params: { claim_id: }

      expect(controller).to have_received(:render).with(locals: { claim:, claim_summary:, core_cost_summary: })
      expect(response).to be_successful
    end
  end
end
