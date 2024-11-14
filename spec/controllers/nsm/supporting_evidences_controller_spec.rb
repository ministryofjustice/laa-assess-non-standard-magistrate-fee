require 'rails_helper'

RSpec.describe Nsm::SupportingEvidencesController do
  context 'show' do
    let(:claim) { build(:claim) }
    let(:claim_id) { claim.id }
    let(:claim_summary) { instance_double(Nsm::V1::ClaimSummary) }
    let(:supporting_evidence) do
      [instance_double(Nsm::V1::SupportingEvidence, file_path: '#', file_name: 'test')]
    end

    before do
      allow(Claim).to receive(:load_from_app_store).and_return(claim)
      allow(BaseViewModel).to receive(:build).with(:claim_summary, anything).and_return(claim_summary)
      allow(BaseViewModel).to receive(:build).with(:supporting_evidence, anything,
                                                   anything).and_return(supporting_evidence)
    end

    it 'find and builds the required object' do
      get :show, params: { claim_id: }

      expect(Claim).to have_received(:load_from_app_store).with(claim_id)
      expect(BaseViewModel).to have_received(:build).with(:supporting_evidence, claim, 'supporting_evidences')
    end

    it 'renders successfully with claims' do
      allow(controller).to receive(:render)
      get :show, params: { claim_id: }

      expect(controller).to have_received(:render).with(locals: { claim:, claim_summary: })
      expect(response).to be_successful
    end
  end
end
