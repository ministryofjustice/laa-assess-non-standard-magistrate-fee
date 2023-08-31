require 'rails_helper'

RSpec.describe ClaimsController do
  context 'show' do
    let(:claim) { instance_double(Claim, current_version_record:, id:) }
    let(:id) { SecureRandom.uuid }
    let(:current_version_record) { instance_double(Version, data:) }
    let(:data) { { 'some' => 'data' } }
    let(:claim_summary) { instance_double(ClaimSummary) }

    before do
      allow(Claim).to receive(:find).and_return(claim)
      allow(ClaimSummary).to receive(:build).and_return(claim_summary)
    end

    it 'find and builds the required object' do
      get :show, params: { id: }

      expect(Claim).to have_received(:find).with(id)
      expect(ClaimSummary).to have_received(:build).with(data)
    end

    it 'renders successfully with claims' do
      allow(controller).to receive(:render)
      get :show, params: { id: }

      expect(controller).to have_received(:render).with(locals: { claim:, claim_summary: })
      expect(response).to be_successful
    end
  end
end
