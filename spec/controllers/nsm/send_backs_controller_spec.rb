require 'rails_helper'

RSpec.describe Nsm::SendBacksController do
  context 'edit' do
    let(:claim) { build(:claim, id: claim_id) }
    let(:claim_id) { SecureRandom.uuid }
    let(:send_back) { instance_double(Nsm::SendBackForm) }

    before do
      allow(Claim).to receive(:find).and_return(claim)
      allow(Nsm::SendBackForm).to receive(:new).and_return(send_back)
    end

    it 'renders successfully with claim' do
      allow(controller).to receive(:render)
      get :edit, params: { claim_id: }

      expect(controller).to have_received(:render)
                        .with(locals: { claim:, send_back: })
      expect(response).to be_successful
    end
  end

  context 'update' do
    let(:send_back) { instance_double(Nsm::SendBackForm, save:) }
    let(:user) { instance_double(User, access_logs:) }
    let(:access_logs) { double(AccessLog, create!: true) }
    let(:claim) { build(:claim, id: SecureRandom.uuid) }
    let(:laa_reference_class) do
      instance_double(Nsm::V1::LaaReference, laa_reference: 'AAA111')
    end
    let(:save) { true }

    before do
      allow(User).to receive(:first_or_create).and_return(user)
      allow(Nsm::SendBackForm).to receive(:new).and_return(send_back)
      allow(BaseViewModel).to receive(:build).and_return(laa_reference_class)
      allow(Claim).to receive(:find).and_return(claim)
    end

    it 'builds a decision object' do
      put :update, params: {
        claim_id: claim.id,
        nsm_send_back_form: { send_back_comment: 'some comment' }
      }
      expect(Nsm::SendBackForm).to have_received(:new).with(
        'send_back_comment' => 'some comment', :claim => claim, 'current_user' => user
      )
    end

    context 'when decision is updated' do
      it 'redirects to claim page' do
        put :update, params: {
          claim_id: claim.id,
          nsm_send_back_form: { send_back_comment: nil, id: claim.id }
        }

        expect(response).to redirect_to(nsm_claim_send_back_path(claim))
      end
    end

    context 'when decision has an error being updated' do
      let(:save) { false }

      it 're-renders the edit page' do
        allow(controller).to receive(:render)
        put :update, params: {
          claim_id: claim.id,
          nsm_send_back_form: { send_back_comment: nil, id: claim.id }
        }

        expect(controller).to have_received(:render)
                          .with(:edit, locals: { claim:, send_back: })
      end
    end
  end
end
