require 'rails_helper'

RSpec.describe LettersAndCallsController do
  context 'index' do
    let(:claim) { instance_double(Claim, id: claim_id) }
    let(:claim_id) { SecureRandom.uuid }
    let(:letter_and_call) { instance_double(V1::LetterAndCall) }
    let(:letters_and_calls_summary) { instance_double(V1::LettersAndCallsSummary) }

    before do
      allow(Claim).to receive(:find).and_return(claim)
      allow(BaseViewModel).to receive_messages(build: letters_and_calls_summary)
      allow(BaseViewModel).to receive_messages(build_all: letter_and_call)
    end

    it 'find and builds the required object' do
      get :index, params: { claim_id: }

      expect(Claim).to have_received(:find).with(claim_id)
      expect(BaseViewModel).to have_received(:build_all).with(:letter_and_call, claim, 'letters_and_calls')
      expect(BaseViewModel).to have_received(:build).with(:letters_and_calls_summary, claim)
    end

    it 'renders successfully with claims' do
      allow(controller).to receive(:render)
      get :index, params: { claim_id: }

      expect(controller).to have_received(:render)
                        .with(locals: { claim: claim, letters_and_calls_items: letter_and_call,
letters_and_calls_summary: letters_and_calls_summary })
      expect(response).to be_successful
    end
  end
end
