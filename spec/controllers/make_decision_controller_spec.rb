require 'rails_helper'

RSpec.describe MakeDecisionController do
  context 'index' do
    let(:claim) { instance_double(Claim, id: claim_id) }
    let(:claim_id) { SecureRandom.uuid }

    before do
      allow(Claim).to receive(:find).and_return(claim)
    end

    it 'renders successfully with claims' do
      allow(controller).to receive(:render)
      get :index, params: { claim_id: }

      expect(controller).to have_received(:render)
                        .with(locals: { claim: })
      expect(response).to be_successful
    end
  end
end
