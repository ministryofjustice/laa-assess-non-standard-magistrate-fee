require 'rails_helper'

RSpec.describe Nsm::SendBacksController do
  context 'edit' do
    let(:claim) { build(:claim, id: claim_id) }
    let(:claim_id) { SecureRandom.uuid }
    let(:send_back) { instance_double(Nsm::SendBackForm) }
    let(:defendant_name) { 'Tracy Linklater' }

    before do
      allow(Claim).to receive(:find).and_return(claim)
      allow(Nsm::SendBackForm).to receive(:new).and_return(send_back)
    end

    it 'renders successfully with claims' do
      allow(controller).to receive(:render)
      get :edit, params: { claim_id: }

      expect(controller).to have_received(:render)
                        .with(locals: { claim:, send_back:, defendant_name: })
      expect(response).to be_successful
    end

    context 'when no m ain defendant' do
      let(:claim) { build(:claim, id: claim_id, data: { 'defendants' => [] }) }

      it 'renders sends a blank defendant_name' do
        defendant_name = ''
        allow(controller).to receive(:render)
        get :edit, params: { claim_id: }

        expect(controller).to have_received(:render)
                          .with(locals: { claim:, send_back:, defendant_name: })
        expect(response).to be_successful
      end
    end
  end

  context 'update' do
    let(:send_back) { instance_double(Nsm::SendBackForm, save:) }
    let(:user) { instance_double(User) }
    let(:claim) { build(:claim, id: SecureRandom.uuid) }
    let(:laa_reference_class) do
      instance_double(Nsm::V1::LaaReference, laa_reference: 'AAA111')
    end
    let(:defendant_name) { 'Tracy Linklater' }
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
        nsm_send_back_form: { comment: 'some commment' }
      }
      expect(Nsm::SendBackForm).to have_received(:new).with(
        'comment' => 'some commment', :claim => claim, 'current_user' => user
      )
    end

    context 'when decision is updated' do
      it 'redirects to claim page' do
        put :update, params: {
          claim_id: claim.id,
          nsm_send_back_form: { comment: nil, id: claim.id }
        }

        expect(response).to redirect_to(your_nsm_claims_path)
        expect(flash[:success]).to eq(
          'You sent back this claim <a ' \
          "class=\"govuk-link\" href=\"/nsm/claims/#{claim.id}/claim_details\">AAA111</a>"
        )
      end
    end

    context 'when decision has an erorr being updated' do
      let(:save) { false }

      it 're-renders the edit page' do
        allow(controller).to receive(:render)
        put :update, params: {
          claim_id: claim.id,
          nsm_send_back_form: { comment: nil, id: claim.id }
        }

        expect(controller).to have_received(:render)
                          .with(:edit, locals: { claim:, send_back:, defendant_name: })
      end
    end
  end
end
