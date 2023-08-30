require 'rails_helper'

RSpec.describe HealthcheckController do
  context 'ping' do
    it 'find and builds the required object' do
      allow(controller).to receive(:render)

      get :ping, format: :json

      expect(response).to be_successful
    end
  end
end
