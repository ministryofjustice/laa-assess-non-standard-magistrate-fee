# frozen_string_literal: true

require 'rails_helper'

RSpec.describe HealthcheckController do
  context 'ping' do
    before do
      get :ping
    end

    it 'renders successfully with 200' do
      expect(response).to have_http_status(:success)
    end

    it 'parsed body does not raise exception' do
      expect { parsed_body }.not_to raise_exception
    end

    it 'displays correct hash values' do
      expect(parsed_body.keys).to include('branch_name')
    end

    it 'find and builds the required object' do
      allow(controller).to receive(:render)

      get :ping, format: :json

      expect(response).to be_successful
    end
  end

  private

  def parsed_body
    response.parsed_body.with_indifferent_access
  end
end
