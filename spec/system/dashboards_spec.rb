require 'rails_helper'

RSpec.describe 'Dashboards' do
  context 'when insights feature flag is enabled' do
    before do
      allow(ENV).to receive(:fetch).and_call_original
      allow(ENV).to receive(:fetch).with('METABASE_PA_DASHBOARD_IDS')
                                   .and_return('14,6')
      allow(ENV).to receive(:fetch).with('METABASE_NSM_DASHBOARD_IDS')
                                   .and_return('14')
      allow(FeatureFlags).to receive(:insights).and_return(double(enabled?: true))
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

    context 'search analytics available' do
      it 'can navigate to search analytics' do
        visit dashboard_path
        click_on 'Search'

        expect(page).to have_css('.govuk-heading-xl', text: 'Search')
        expect(page).to have_css('.govuk-label', text: 'Claim or application details')
      end
    end
  end
end
