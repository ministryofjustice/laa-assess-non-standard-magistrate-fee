require 'rails_helper'

RSpec.describe DashboardsController do
  describe '#show' do
    context 'dashboard ids not set' do
      let(:search_form) { nil }
      let(:search_form_instance) { instance_double(SearchForm, valid?: true, execute: true) }

      before do
        allow(ENV).to receive(:fetch).and_call_original
        allow(ENV).to receive(:fetch).with('METABASE_PA_DASHBOARD_IDS')
                                     .and_return(nil)
        allow(ENV).to receive(:fetch).with('METABASE_NSM_DASHBOARD_IDS')
                                     .and_return(nil)
        allow(FeatureFlags).to receive(:nsm_insights).and_return(double(enabled?: true))
        allow(subject).to receive(:authorize_supervisor).and_return(true)
        allow(SearchForm).to receive(:new).and_return(search_form_instance)
        get :show, params: { nav_select:, search_form: }
      end

      context 'selected tab is search' do
        let(:nav_select) { 'search' }
        let(:search_form) { { query: 'query' } }

        context 'user has executed a valid search' do
          it 'generates a SearchForm' do
            expect(subject.instance_variable_get(:@search_form)).to eq(search_form_instance)
          end

          it 'executes a search' do
            expect(search_form_instance).to have_received(:execute)
          end
        end

        context 'user has executed a invalid search' do
          let(:search_form_instance) { instance_double(SearchForm, valid?: false, execute: true) }

          it 'generates a SearchForm' do
            expect(subject.instance_variable_get(:@search_form)).to eq(search_form_instance)
          end

          it 'does not execute a search' do
            expect(search_form_instance).not_to have_received(:execute)
          end
        end
      end

      context 'selected tab is prior authority' do
        let(:nav_select) { 'prior_authority' }

        it 'returns no urls' do
          expect(subject.instance_variable_get(:@iframe_urls)).to eq([])
        end
      end

      context 'selected tab is nsm' do
        let(:nav_select) { 'nsm' }

        it 'returns no urls' do
          expect(subject.instance_variable_get(:@iframe_urls)).to eq([])
        end
      end

      context 'invalid service provided' do
        let(:nav_select) { 'random' }

        it 'returns no ids' do
          expect(subject.instance_variable_get(:@iframe_urls)).to eq([])
        end
      end
    end
  end
end
