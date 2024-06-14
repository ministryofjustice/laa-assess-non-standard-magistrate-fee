require 'rails_helper'

RSpec.describe 'Dashboards' do
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
