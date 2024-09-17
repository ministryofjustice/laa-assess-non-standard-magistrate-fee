require 'rails_helper'

RSpec.describe 'Maintenance mode' do
  context 'when maintenance mode is enabled via env var' do
    before do
      ENV['MAINTENANCE_MODE'] = 'true'
    end

    it 'shows the maintenance screen on all URLS' do
      visit closed_nsm_claims_path
      expect(page).to have_content 'Sorry, the service is unavailable'
    end
  end

  context 'when maintenance mode is enabled via feature flag' do
    let(:mode) { instance_double(FeatureFlags::EnabledFeature, enabled?: true) }

    before do
      allow(FeatureFlags).to receive(:maintenance_mode).and_return(mode)
      ENV['MAINTENANCE_MODE'] = 'true'
    end

    it 'shows the maintenance screen on all URLS' do
      visit closed_nsm_claims_path
      expect(page).to have_content 'Sorry, the service is unavailable'
    end
  end
end
