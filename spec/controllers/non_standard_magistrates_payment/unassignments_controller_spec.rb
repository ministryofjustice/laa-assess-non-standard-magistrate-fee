require 'rails_helper'

RSpec.describe NonStandardMagistratesPayment::UnassignmentsController do
  context 'edit' do
    let(:claim) { build(:claim, id: claim_id) }
    let(:claim_id) { SecureRandom.uuid }
    let(:unassignment) { instance_double(UnassignmentForm) }
    let(:defendant_name) { 'Tracy Linklater' }

    before do
      allow(Claim).to receive(:find).and_return(claim)
      allow(UnassignmentForm).to receive(:new).and_return(unassignment)
    end

    it 'renders successfully with claims' do
      allow(controller).to receive(:render)
      get :edit, params: { claim_id: }

      expect(controller).to have_received(:render)
                        .with(locals: { claim:, unassignment: })
      expect(response).to be_successful
    end
  end

  context 'update' do
    let(:unassignment) { instance_double(UnassignmentForm, save:, unassignment_user:, user:) }
    let(:unassignment_user) { 'other' }
    let(:user) { instance_double(User, display_name: 'Jim Bob') }
    let(:claim) { create(:claim, :with_assignment) }
    let(:laa_reference_class) { instance_double(V1::LaaReference, laa_reference: 'AAA111') }
    let(:defendant_name) { 'Tracy Linklater' }
    let(:save) { true }

    before do
      allow(User).to receive(:first_or_create).and_return(user)
      allow(UnassignmentForm).to receive(:new).and_return(unassignment)
      allow(BaseViewModel).to receive(:build).and_return(laa_reference_class)
      allow(Claim).to receive(:find).and_return(claim)
    end

    it 'builds a decision object' do
      put :update, params: {
        claim_id: claim.id,
        unassignment_form: { comment: 'some commment' }
      }
      expect(UnassignmentForm).to have_received(:new).with(
        'comment' => 'some commment', :claim => claim, 'current_user' => user
      )
    end

    context 'when decision is updated' do
      it 'redirects to claim page' do
        put :update, params: {
          claim_id: claim.id,
          unassignment_form: { comment: nil, id: claim.id }
        }

        expect(response).to redirect_to(non_standard_magistrates_payment_your_claims_path)
        expect(flash[:success]).to eq(
          'Claim <a class="govuk-link" href="' \
          "/non_standard_magistrates_payment/claims/#{claim.id}/claim_details\">AAA111</a> " \
          "has been removed from Jim Bob's list"
        )
      end

      context 'when current_user is the assigned user' do
        let(:unassignment_user) { 'assigned' }

        it 'redirects to claim page' do
          put :update, params: {
            claim_id: claim.id,
            unassignment_form: { state: 'further_info', comment: nil, id: claim.id }
          }

          expect(response).to redirect_to(non_standard_magistrates_payment_your_claims_path)
          expect(flash[:success]).to eq(
            '<a class="govuk-link" ' \
            "href=\"/non_standard_magistrates_payment/claims/#{claim.id}/claim_details\">AAA111</a> " \
            'has been removed from your list'
          )
        end
      end
    end

    context 'when decision has an erorr being updated' do
      let(:save) { false }

      it 're-renders the edit page' do
        allow(controller).to receive(:render)
        put :update, params: {
          claim_id: claim.id,
          unassignment_form: { comment: nil, id: claim.id }
        }

        expect(controller).to have_received(:render)
                          .with(:edit, locals: { claim:, unassignment: })
      end
    end
  end
end