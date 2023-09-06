require 'rails_helper'

RSpec.describe ApplicationVersionsController do
  describe '#update' do
    let(:receiver) { instance_double(ReceiveApplicationMetadata, save:) }
    let(:save) { true }
    let(:params) do
      {
        id: id,
        application: {
          id: id,
          risk: 'high',
          current_version: 1,
          state: 'submitted'
        }
      }
    end
    let(:id) { SecureRandom.uuid }

    before do
      allow(ReceiveApplicationMetadata).to receive(:new).and_return(receiver)
    end

    it 'sends the param to the receiver on save' do
      put(:update, params:)

      application_params = {
        'id' => id,
        'risk' => 'high',
        'current_version' => '1',
      }
      expect(receiver).to have_received(:save).with(application_params, 'submitted')
    end

    context 'when the receiver saves the metadata' do
      it 'renders head ok' do
        put(:update, params:)

        expect(response).to be_successful
      end
    end

    context 'when the receiver fails to save the metadata' do
      let(:save) { false }

      before do
        allow(receiver).to receive(:errors).and_return('claim_errors')
      end

      it 'renders head a 401 error' do
        put(:update, params:)

        expect(response).to have_http_status(:unauthorized)
        expect(response.parsed_body).to eq('error' => 'claim_errors')
      end
    end
  end
end
