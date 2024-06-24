require 'rails_helper'

RSpec.describe DashboardsController do
  describe '#generate_dashboards' do
    context 'dashboard ids not set' do
      before do
        allow(ENV).to receive(:fetch).and_call_original
        allow(ENV).to receive(:fetch).with('METABASE_PA_DASHBOARD_IDS')
                                     .and_return(nil)
        allow(ENV).to receive(:fetch).with('METABASE_NSM_DASHBOARD_IDS')
                                     .and_return(nil)
        allow(FeatureFlags).to receive(:nsm).and_return(double(enabled?: true))
        allow(subject).to receive(:authorize_supervisor).and_return(true)
      end

      context 'show' do
        context 'service is prior authority' do
          before do
            get :show, params: { service: 'prior_authority' }
          end

          it 'returns no urls' do
            expect(subject.instance_variable_get(:@iframe_urls)).to eq([])
          end
        end

        context 'service is nsm' do
          before do
            get :show, params: { service: 'nsm' }
          end

          it 'returns no urls' do
            expect(subject.instance_variable_get(:@iframe_urls)).to eq([])
          end
        end

        context 'invalid service provided' do
          before do
            get :show, params: { service: 'random' }
          end

          it 'returns no ids' do
            expect(subject.instance_variable_get(:@iframe_urls)).to eq([])
          end
        end
      end
    end
  end
end
