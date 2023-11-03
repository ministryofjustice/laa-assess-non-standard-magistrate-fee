require 'rails_helper'

RSpec.describe ClaimsController do
  describe '#index' do
    it 'does not raise any errors' do
      expect { get :index }.not_to raise_error
    end
  end

  describe '#new' do
    context 'when a claim is available to assign' do
      it 'creates an assignment and event' do
        create(:claim)

        expect do
          expect { get :new }.to change(Assignment, :count).by(1)
        end.to change(Event::Assignment, :count).by(1)
      end

      it 'redirects to the assigned claim' do
        claim = create(:claim)

        get :new

        expect(response).to redirect_to(claim_claim_details_path(claim))
      end
    end

    context 'when a claim is not available to assign' do
      it 'redirects to Your Claims with a flash notice' do
        get :new

        expect(response).to redirect_to(your_claims_path)
        expect(flash[:notice]).to eq('There are no claims waiting to be allocated.')
      end
    end
  end

  describe '#destroy' do
    let(:claim) { create(:claim) }

    context 'when an assignment exists' do
      let(:user) { create(:caseworker) }

      it 'deletes the assignment and create an Unassignment event' do
        claim.assignments.create(user:)

        expect do
          expect { delete :destroy, params: { id: claim.id } }.to change(Assignment, :count).by(-1)
        end.to change(Event::Unassignment, :count).by(1)
      end

      it 'redirects to Your Claims' do
        claim.assignments.create(user:)

        delete :destroy, params: { id: claim.id }

        expect(response).to redirect_to(your_claims_path)
      end
    end

    context 'when no assignment exists' do
      it 'does nothing' do
        expect(Event::Unassignment).not_to receive(:build)

        delete :destroy, params: { id: claim.id }
      end

      it 'redirects to Your Claims' do
        delete :destroy, params: { id: claim.id }

        expect(response).to redirect_to(your_claims_path)
      end
    end
  end
end
