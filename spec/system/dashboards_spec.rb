require 'rails_helper'

RSpec.describe 'Dashboards' do
  context 'when insights feature flag is enabled' do
    before do
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
        click_on 'View insights'
        expect(page).to have_current_path(dashboard_path)
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
        expect(page).not_to have_text('View insights')
      end

      it 'does not let me visit the dashboard path' do
        visit dashboard_path
        expect(page).to have_current_path(root_path)
      end
    end
  end
end
