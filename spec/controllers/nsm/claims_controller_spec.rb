require 'rails_helper'

RSpec.describe Nsm::ClaimsController, :stub_oauth_token do
  before do
    stub_request(:post, 'https://appstore.example.com/v1/submissions/searches').to_return(
      status: 201,
      body: { metadata: { total_results: 0 }, raw_data: [] }.to_json
    )
  end

  describe '#your' do
    it 'does not raise any errors' do
      expect { get :your }.not_to raise_error
    end
  end

  describe '#open' do
    it 'does not raise any errors' do
      expect { get :open }.not_to raise_error
    end
  end

  describe '#closed' do
    it 'does not raise any errors' do
      expect { get :closed }.not_to raise_error
    end
  end

  describe '#create', :stub_oauth_token do
    let(:assignment_stub) do
      stub_request(:post, "https://appstore.example.com/v1/submissions/#{claim.id}/assignment").to_return(status: 201)
    end

    let(:claim) { create(:claim) }

    context 'when a claim is available to assign' do
      it 'creates an assignment and event' do
        assignment_stub

        expect do
          expect { post :create }.to change(Assignment, :count).by(1)
        end.to change(Event::Assignment, :count).by(1)
      end

      it 'redirects to the assigned claim' do
        assignment_stub

        post :create

        expect(response).to redirect_to(nsm_claim_claim_details_path(claim))
      end

      it 'tells the app store' do
        assignment_stub

        post :create

        expect(assignment_stub).to have_been_requested
      end
    end

    context 'when a claim is not available to assign' do
      it 'redirects to Your Claims with a flash notice' do
        post :create

        expect(response).to redirect_to(your_nsm_claims_path)
        expect(flash[:notice]).to eq('There are no claims waiting to be allocated.')
      end
    end
  end
end
