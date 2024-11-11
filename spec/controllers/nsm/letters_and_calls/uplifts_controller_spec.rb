require 'rails_helper'

RSpec.describe Nsm::LettersAndCalls::UpliftsController do
  let(:claim) { create :claim }
  let(:user) { create :caseworker }

  before do
    allow(controller).to receive(:current_user).and_return(user)
    create :assignment, submission: claim, user: user
  end

  describe 'edit' do
    it 'renders successfully' do
      get :edit, params: { claim_id: claim.id }
      expect(response).to be_successful
    end
  end

  describe 'update' do
    let(:form) { instance_double(Nsm::Uplift::LettersAndCallsForm, save!: save) }

    before do
      allow(Nsm::Uplift::LettersAndCallsForm).to receive(:new).and_return(form)
      put :update,
          params: { claim_id: claim.id,
                    nsm_uplift_letters_and_calls_form: { some: :data } }
    end

    context 'when form save is successful' do
      let(:save) { true }

      it 'redirects' do
        expect(controller).to redirect_to(
          nsm_claim_letters_and_calls_path(claim)
        )
      end
    end

    context 'when form save is unsuccessful' do
      let(:save) { false }

      it 'renders rather than redirects' do
        expect(response).to be_successful
      end
    end
  end
end
