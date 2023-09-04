require 'rails_helper'

RSpec.describe ClaimDetailsController do
  context 'show' do
    let(:claim) { instance_double(Claim, current_version_record: current_version_record, id: claim_id) }
    let(:claim_id) { SecureRandom.uuid }
    let(:current_version_record) { instance_double(Version, data:) }
    let(:data) { { 'some' => 'data' } }
    let(:claim_summary) { instance_double(ClaimSummary) }
    let(:claim_details) { an_instance_of(Hash) }

    before do
      allow(Claim).to receive(:find).and_return(claim)
      allow(ClaimSummary).to receive(:build).and_return(claim_summary)
    end

    it 'find and builds the required object' do
      get :show, params: { claim_id: }

      expect(Claim).to have_received(:find).with(claim_id)
      expect(ClaimSummary).to have_received(:build).with(data)
    end

    it 'renders successfully with claims' do
      allow(controller).to receive(:render)
      get :show, params: { claim_id: }

      expect(controller).to have_received(:render).with(locals: { claim:, claim_summary:, claim_details: })
      expect(response).to be_successful
    end
  end
end
