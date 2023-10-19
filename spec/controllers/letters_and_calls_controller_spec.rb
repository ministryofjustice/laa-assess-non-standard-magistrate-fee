require 'rails_helper'

RSpec.describe LettersAndCallsController do
  describe '#index' do
    let(:claim) { instance_double(Claim, id: claim_id) }
    let(:claim_id) { SecureRandom.uuid }
    let(:letters_and_calls) { instance_double(V1::LettersAndCallsSummary) }

    before do
      allow(Claim).to receive(:find).and_return(claim)
      allow(BaseViewModel).to receive_messages(build: letters_and_calls)
    end

    it 'find and builds the required object' do
      get :index, params: { claim_id: }

      expect(Claim).to have_received(:find).with(claim_id)
      expect(BaseViewModel).to have_received(:build).with(:letters_and_calls_summary, claim)
    end

    it 'renders successfully with claims' do
      allow(controller).to receive(:render)
      get :index, params: { claim_id: }

      expect(controller).to have_received(:render)
                        .with(locals: { claim:, letters_and_calls: })
      expect(response).to be_successful
    end
  end

  context 'edit' do
    let(:claim) { instance_double(Claim, id: claim_id, risk: 'high') }
    let(:claim_id) { SecureRandom.uuid }
    let(:form) { instance_double(LettersCallsForm) }
    let(:letters_and_calls) { [calls, letters] }
    let(:calls) { instance_double(V1::LetterAndCall, type: double(value: 'calls'), form_attributes: {}) }
    let(:letters) { instance_double(V1::LetterAndCall, type: double(value: 'letters'), form_attributes: {}) }

    before do
      allow(Claim).to receive(:find).and_return(claim)
      allow(BaseViewModel).to receive(:build_all).and_return(letters_and_calls)
      allow(LettersCallsForm).to receive(:new).and_return(form)
    end

    context 'when URL is for letters' do
      it 'renders successfully with claims' do
        allow(controller).to receive(:render)
        get :edit, params: { claim_id: claim_id, id: 'letters' }

        expect(controller).to have_received(:render)
                          .with(locals: { claim: claim, form: form, item: letters })
        expect(response).to be_successful
      end
    end

    context 'when URL is for calls' do
      it 'renders successfully with claims' do
        allow(controller).to receive(:render)
        get :edit, params: { claim_id: claim_id, id: 'calls' }

        expect(controller).to have_received(:render)
                          .with(locals: { claim: claim, form: form, item: calls })
        expect(response).to be_successful
      end
    end
  end
end
