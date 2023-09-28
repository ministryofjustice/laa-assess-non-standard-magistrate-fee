require 'rails_helper'

RSpec.describe SendBackController do
  context 'index' do
    let(:claim) { instance_double(Claim, id: claim_id) }
    let(:claim_id) { SecureRandom.uuid }
    let(:claim_summary) { instance_double(V1::ClaimSummary) }

    before do
      allow(Claim).to receive(:find).and_return(claim)
      allow(BaseViewModel).to receive_messages(build: claim_summary)
    end

    it 'renders successfully with claims' do
      allow(controller).to receive(:render)
      get :index, params: { claim_id: }

      expect(controller).to have_received(:render)
                        .with(locals: { claim_summary: })
      expect(response).to be_successful
    end
  end
end
