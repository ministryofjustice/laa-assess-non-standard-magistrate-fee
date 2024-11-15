require 'rails_helper'

RSpec.describe 'Dashboards', :stub_oauth_token do
  context 'when insights feature flag is enabled' do
    before do
      allow(ENV).to receive(:fetch).and_call_original
      allow(ENV).to receive(:fetch).with('METABASE_PA_DASHBOARD_IDS')
                                   .and_return('14,6')
      allow(ENV).to receive(:fetch).with('METABASE_NSM_DASHBOARD_IDS')
                                   .and_return('14')
      allow(FeatureFlags).to receive_messages(insights: double(enabled?: true), nsm_insights: double(enabled?: true))
    end

    context 'when I am not a supervisor' do
      before { sign_in create(:caseworker) }

      it 'does not let me visit the dashboard path' do
        visit dashboard_path
        expect(page).to have_current_path(root_path)
      end
    end

    context 'when I am a supervisor' do
      before { sign_in create(:supervisor) }

      it 'lets me visit the dashboard path' do
        visit root_path
        click_on 'Analytics dashboard'
        expect(page).to have_current_path(new_dashboard_path)
      end

      it 'by default lets me view the prior authority analytics' do
        visit dashboard_path
        expect(page).to have_css('.govuk-heading-xl', text: 'Prior authority')
        expect(page).to have_css('.moj-primary-navigation__link', text: 'Prior authority')
      end

      context 'when nsm feature flag is enabled' do
        before do
          allow(FeatureFlags).to receive(:nsm_insights).and_return(double(enabled?: true))
          visit dashboard_path
        end

        it 'shows both service navigation tabs and search tab' do
          expect(page).to have_css('.moj-primary-navigation__link', text: 'Prior authority')
          expect(page).to have_css('.moj-primary-navigation__link', text: 'Non-standard magistrates')
          expect(page).to have_css('.moj-primary-navigation__link', text: 'Search')
        end

        it 'can navigate to nsm analytics' do
          click_on 'Non-standard magistrates'
          expect(page).to have_current_path(new_dashboard_path(nav_select: 'nsm'))

          expect(page).to have_css('.govuk-heading-xl', text: 'Non-standard magistrates')
        end
      end

      context 'when nsm feature flag is disabled' do
        before do
          allow(FeatureFlags).to receive(:nsm_insights).and_return(double(enabled?: false))
          visit dashboard_path
        end

        it 'does not have tab to navigate to nsm analytics' do
          expect(page).not_to have_text('Non-standard magistrates')
        end

        it 'cannot navigate to nsm page' do
          visit new_dashboard_path(nav_select: 'nsm')

          expect(page).to have_css('.govuk-heading-xl', text: 'Prior authority')
        end

        context 'using search' do
          let(:endpoint) { 'https://appstore.example.com/v1/submissions/searches' }
          let(:payload) do
            {
              application_type: 'crm4',
              page: 1,
              query: 'LAA-ABCDEF',
              per_page: 20,
              sort_by: 'last_updated',
              sort_direction: 'descending',
            }
          end

          let(:stub) do
            stub_request(:post, endpoint).with(body: payload).to_return(
              status: 200,
              body: { metadata: { total_results: 0 }, raw_data: [] }.to_json
            )
          end

          before do
            stub
            visit dashboard_path
            click_on 'Search'
          end

          it 'automatically defaults to CRM4 search' do
            within('.search-panel') do
              fill_in 'Enter any combination', with: 'LAA-ABCDEF'
              click_on 'Search'
            end
          end

          it 'does not show options for application type' do
            expect(page).not_to have_text('Which service do you want to search?')
          end
        end
      end

      context 'when dashboard ids are not provided' do
        before do
          allow(ENV).to receive(:fetch).with('METABASE_PA_DASHBOARD_IDS')
                                       .and_return(nil)
          allow(ENV).to receive(:fetch).with('METABASE_NSM_DASHBOARD_IDS')
                                       .and_return(nil)
          allow(FeatureFlags).to receive(:nsm_insights).and_return(double(enabled?: true))
        end

        it 'does not show any prior authority dashboards' do
          visit dashboard_path
          expect(page).not_to have_css('iframe')
        end

        it 'does not show any nsm dashboards' do
          visit dashboard_path(nav_select: 'nsm')
          expect(page).not_to have_css('iframe')
        end
      end

      context 'search analytics available' do
        let(:applications) do
          build_list(:prior_authority_application,
                     20) + build_list(:prior_authority_application, 1, state: 'sent_back', updated_at: Date.yesterday - 1)
        end
        let(:endpoint) { 'https://appstore.example.com/v1/submissions/searches' }
        let(:search_stub) do
          stub_request(:post, endpoint).with(body: search_payload).to_return(
            status: 201, body: { metadata: { total_results: 21 },
                                 raw_data: applications.map do |app|
                                   { application_id: app.id, application: app.data, application_type: 'crm7',
                                     last_updated_at: 1.day.ago, application_state: app.state }
                                 end }.to_json
          )
        end

        let(:sort_stub) do
          stub_request(:post, endpoint).with(body: sort_payload).to_return(
            status: 201, body: { metadata: { total_results: 21 },
                                 raw_data: applications.map do |app|
                                   { application_id: app.id, application: app.data, application_type: 'crm7',
                                     last_updated_at: 1.day.ago, application_state: app.state }
                                 end }.to_json
          )
        end

        context 'valid search' do
          let(:search_payload) do
            {
              application_type: 'crm4',
              query: 'Foo',
              page: 1,
              per_page: 20,
              sort_by: 'last_updated',
              sort_direction: 'descending',
            }
          end
          let(:sort_payload) do
            {
              application_type: 'crm4',
              query: 'Foo',
              page: 1,
              per_page: 20,
              sort_by: 'status_with_assignment',
              sort_direction: 'ascending',
            }
          end

          before do
            search_stub
            sort_stub
            visit dashboard_path
            click_on 'Search'
          end

          it 'can navigate to search analytics' do
            expect(page).to have_css('.govuk-heading-xl', text: 'Search')
            expect(page).to have_css('.govuk-label', text: 'Enter any combination of client or firm name, UFN or LAA reference')
          end

          it 'can search for submissions' do
            within('.search-panel') do
              choose 'Prior authority'
              fill_in 'Enter any combination', with: 'Foo'
              click_on 'Search'
            end

            expect(search_stub).to have_been_requested
          end

          it 'can sort results' do
            within('.search-panel') do
              choose 'Prior authority'
              fill_in 'Enter any combination', with: 'Foo'
              click_on 'Search'
            end

            expect(page).to have_css('.govuk-table')
            click_link 'Status'
            expect(sort_stub).to have_been_requested
            expect(page.find('.govuk-table')).to have_text 'Sent back'
          end
        end

        context 'application_type missing' do
          let(:search_payload) do
            {
              query: 'test',
              page: 1,
              per_page: 20,
              sort_by: 'last_updated',
              sort_direction: 'descending',
            }
          end

          before do
            search_stub
            visit dashboard_path
            click_on 'Search'
          end

          it 'shows validation error' do
            within('.search-panel') do
              fill_in 'Enter any combination', with: 'test'
              click_on 'Search'
            end

            expect(page.find('.govuk-error-message')).to have_text 'Select a service to search'
          end
        end
      end
    end
  end

  context 'when insights feature flag is disabled' do
    before do
      allow(FeatureFlags).to receive(:insights).and_return(double(enabled?: false))
    end

    context 'when I am a supervisor' do
      before { sign_in create(:supervisor) }

      it 'does not show link for insights' do
        visit root_path
        expect(page).not_to have_text('Analytics dashboard')
      end

      it 'does not let me visit the dashboard path' do
        visit dashboard_path
        expect(page).to have_current_path(root_path)
      end
    end
  end
end
