require 'rails_helper'

RSpec.describe 'Notes', :stub_oauth_token do
  let(:caseworker) { create(:caseworker, first_name: 'Jane', last_name: 'Bloggs') }
  let(:application) { build(:prior_authority_application, state: 'submitted') }

  before do
    stub_app_store_interactions(application)
    sign_in caseworker
    application.assigned_user_id = caseworker.id
    visit prior_authority_application_events_path(application)
    click_on 'Add a note to the application history'
  end

  context 'when I add a note' do
    before do
      fill_in 'Add a note to the application history', with: 'Here is a note'
      click_on 'Save and continue'
    end

    it 'adds a note' do
      expect(page).to have_content('Jane Bloggs added a note')
        .and have_content 'Here is a note'
    end
  end

  context 'when I leave it blank' do
    before do
      click_on 'Save and continue'
    end

    it 'shows an error message' do
      expect(page).to have_content 'Enter what information you want added to the application history'
    end
  end
end
