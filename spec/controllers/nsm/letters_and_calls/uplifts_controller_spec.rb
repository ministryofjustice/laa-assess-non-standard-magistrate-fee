require 'rails_helper'

RSpec.describe Nsm::LettersAndCalls::UpliftsController do
  context 'edit' do
    let(:claim) { instance_double(Claim, id: claim_id, risk: 'high') }
    let(:claim_id) { SecureRandom.uuid }
    let(:form) { instance_double(Nsm::Uplift::LettersAndCallsForm) }

    before do
      allow(Claim).to receive(:find).and_return(claim)
      allow(Nsm::Uplift::LettersAndCallsForm).to receive(:new).and_return(form)
    end

    it 'renders successfully with claims' do
      allow(controller).to receive(:render)
      get :edit, params: { claim_id: }

      expect(controller).to have_received(:render)
                        .with(locals: { claim:, form: })
      expect(response).to be_successful
    end
  end

  context 'update' do
    let(:claim) { instance_double(Claim, id: claim_id, risk: 'high') }
    let(:claim_id) { SecureRandom.uuid }
    let(:form) { instance_double(Nsm::Uplift::LettersAndCallsForm, save:) }

    before do
      allow(Nsm::Uplift::LettersAndCallsForm).to receive(:new).and_return(form)
      allow(Claim).to receive(:find).and_return(claim)
    end

    context 'when form save is successful' do
      let(:save) { true }

      it 'renders successfully with claims' do
        allow(controller).to receive(:render)
        put :update,
            params: { claim_id: claim_id,
nsm_uplift_letters_and_calls_form: { some: :data } }

        expect(controller).to redirect_to(
          nsm_claim_adjustments_path(claim,
                                                                  anchor: 'letters-and-calls-tab')
        )
        expect(response).to have_http_status(:found)
      end
    end

    context 'when form save is unsuccessful' do
      let(:save) { false }

      it 'renders successfully with claims' do
        allow(controller).to receive(:render)
        put :update,
            params: { claim_id: claim_id,
nsm_uplift_letters_and_calls_form: { some: :data } }

        expect(controller).to have_received(:render)
                          .with(:edit, locals: { claim:, form: })
        expect(response).to be_successful
      end
    end
  end
end
