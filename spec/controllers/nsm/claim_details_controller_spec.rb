require 'rails_helper'

RSpec.describe Nsm::ClaimDetailsController do
  context 'show' do
    let(:claim) { instance_double(Claim, id: claim_id, data: {}) }
    let(:claim_id) { SecureRandom.uuid }
    let(:claim_summary) { instance_double(Nsm::V1::ClaimSummary) }
    let(:claim_details) { instance_double(ClaimDetails::Table) }
    let(:provider_updates) { nil }

    before do
      allow(Claim).to receive(:find).and_return(claim)
      allow(BaseViewModel).to receive(:build).with(:claim_summary, claim).and_return(claim_summary)
      allow(ClaimDetails::Table).to receive(:new).and_return(claim_details)
    end

    it 'find and builds the required object' do
      get :show, params: { claim_id: }

      expect(Claim).to have_received(:find).with(claim_id)
      expect(BaseViewModel).to have_received(:build).with(:claim_summary, claim)
    end

    it 'renders successfully with claims' do
      allow(controller).to receive(:render)
      get :show, params: { claim_id: }

      expect(controller).to have_received(:render).with(locals: { claim:, claim_summary:, claim_details:, provider_updates: })
      expect(response).to be_successful
    end

    describe 'has further_information' do
      let(:data) { { 'further_information' => { 'information_requested' => 'requesting...' } } }
      let(:claim) { instance_double(Claim, id: claim_id, data: data) }
      let(:further_information) { [instance_double(Nsm::V1::FurtherInformation)] }

      before do
        allow(further_information).to receive(:sort_by).and_return true
        allow(BaseViewModel).to receive(:build)
          .with(:further_information, claim, 'further_information')
          .and_return(further_information)
      end

      it 'build the further information object array and sort_by' do
        get :show, params: { claim_id: }

        expect(further_information).to have_received(:sort_by)
      end
    end
  end
end
