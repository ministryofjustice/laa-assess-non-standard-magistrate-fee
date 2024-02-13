require 'rails_helper'

RSpec.describe Nsm::ClaimsController do
  describe '#index' do
    before { allow(AppStoreService).to receive(:list).and_return([[], 0]) }

    it 'does not raise any errors' do
      expect { get :index }.not_to raise_error
    end
  end

  describe '#new' do
    context 'when a claim is available to assign' do
      it 'redirects to the assigned claim' do
        claim = build(:claim)
        expect(AppStoreService).to receive(:assign).and_return(claim)

        get :new

        expect(response).to redirect_to(nsm_claim_claim_details_path(claim))
      end
    end

    context 'when a claim is not available to assign' do
      it 'redirects to Your Claims with a flash notice' do
        expect(AppStoreService).to receive(:assign).and_return(nil)
        get :new

        expect(response).to redirect_to(nsm_your_claims_path)
        expect(flash[:notice]).to eq('There are no claims waiting to be allocated.')
      end
    end
  end
end
