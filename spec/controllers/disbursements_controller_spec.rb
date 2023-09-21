require 'rails_helper'

RSpec.describe DisbursementsController do
  context 'index' do
    let(:claim) { instance_double(Claim, id: claim_id) }
    let(:claim_id) { SecureRandom.uuid }
    let(:disbursements) { [instance_double(V1::Disbursement, disbursement_date: Time.zone.today)] }
    let(:grouped_disbursements) { { Time.zone.today => disbursements } }

    before do
      allow(Claim).to receive(:find).and_return(claim)
      allow(BaseViewModel).to receive_messages(build_all: disbursements)
    end

    it 'find and builds the required object' do
      get :index, params: { claim_id: }

      expect(Claim).to have_received(:find).with(claim_id)
      expect(BaseViewModel).to have_received(:build_all).with(:disbursement, claim, 'disbursements')
    end

    it 'renders successfully with claims' do
      allow(controller).to receive(:render)
      get :index, params: { claim_id: }

      expect(controller).to have_received(:render).with(locals: { claim: claim, disbursements: grouped_disbursements })
      expect(response).to be_successful
    end
  end
end
