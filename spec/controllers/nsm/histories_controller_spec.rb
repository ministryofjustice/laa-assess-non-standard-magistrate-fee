require 'rails_helper'

RSpec.describe Nsm::HistoriesController do
  describe 'show' do
    let(:claim) { build(:claim, id: claim_id, events: events) }
    let(:claim_id) { SecureRandom.uuid }
    let(:events) { [build(:event, :note)] }
    let(:claim_summary) { instance_double(Nsm::V1::ClaimSummary) }
    let(:claim_note) { instance_double(Nsm::ClaimNoteForm, claim:) }

    before do
      allow(Claim).to receive(:load_from_app_store).and_return(claim)
      allow(BaseViewModel).to receive_messages(build: claim_summary)
      allow(Nsm::ClaimNoteForm).to receive(:new).and_return(claim_note)
    end

    it 'find and builds the required object' do
      get :show, params: { claim_id: }

      expect(BaseViewModel).to have_received(:build).with(:claim_summary, claim)
    end

    it 'renders successfully' do
      allow(controller).to receive(:render)
      get :show, params: { claim_id: }

      expect(controller).to have_received(:render).with(
        locals: {
          claim: claim, claim_summary: claim_summary, history_events: claim.events,
          claim_note: claim_note, pagy: anything
        }
      )
      expect(response).to be_successful
    end
  end

  describe 'create' do
    let(:user) { create :caseworker }
    let(:claim) { build :claim }
    let(:form) { instance_double(Nsm::ClaimNoteForm, claim:, save:) }

    before do
      allow(Claim).to receive(:load_from_app_store).and_return(claim)
      claim.assigned_user_id = user.id
      allow(Nsm::ClaimNoteForm).to receive(:new).and_return(form)
      post :create, params: {
        claim_id: claim.id,
        nsm_claim_note_form: { note: 'new note', id: claim.id }
      }
    end

    context 'when save succeeds' do
      let(:save) { true }

      it 'builds a note object' do
        expect(controller).to redirect_to(
          nsm_claim_history_path(claim)
        )
      end
    end

    context 'when decision has an erorr being updated' do
      let(:save) { false }

      it 're-renders the edit page' do
        expect(response).to be_successful
      end
    end
  end
end
