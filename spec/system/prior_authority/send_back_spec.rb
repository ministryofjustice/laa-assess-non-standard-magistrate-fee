require 'rails_helper'

RSpec.describe 'Send an application back', :stub_oauth_token do
  let(:caseworker) { create(:caseworker) }
  let(:application) { create(:prior_authority_application, state: 'submitted') }

  before do
    sign_in caseworker
    create(:assignment, submission: application, user: caseworker)
    visit '/'
    click_on 'Accept analytics cookies'
    visit prior_authority_application_path(application)
    click_on 'Send back to provider'
  end

  context 'when I send the application back' do
    before do
      check 'Further information'
      fill_in 'Describe what further information you require', with: 'You forgot to say please'
    end

    it 'triggers an app store stync' do
      expect { click_on 'Submit' }.to have_enqueued_job(NotifyAppStore)
    end

    context 'once the decision has been processed' do
      before do
        click_on 'Submit'
      end

      it 'shows my application' do
        expect(page).to have_content 'Application sent'
        expect(page).to have_content 'Further information You forgot to say please'
      end

      it 'shows the decision in the history' do
        visit prior_authority_application_events_path(application)
        expect(page).to have_content 'Sent back'
      end

      it 'removes the edit buttons from the application page' do
        click_on 'Return to this application'
        expect(page).to have_no_content 'Make a decision'
      end

      it 'prevents duplicate submission' do
        visit new_prior_authority_application_send_back_path(application)
        click_on 'Submit'
        expect(page).to have_content 'This application has already been assessed'
      end
    end
  end

  it 'requires me to choose an option' do
    click_on 'Submit'
    expect(page).to have_content 'Select what updates to the application are needed'
  end

  it 'requires an explanation for further information requests' do
    check 'Further information'
    click_on 'Submit'
    expect(page).to have_content 'Enter a description of what further information your require'
  end

  it 'requires an explanation for incorrect information requests' do
    check 'Incorrect information'
    click_on 'Submit'
    expect(page).to have_content 'Enter a description of what information is incorrect and needs amending'
  end

  it 'lets me save my answers and return later' do
    check 'Further information'
    fill_in 'Describe what further information you require', with: 'You forgot to say please'
    click_on 'Save and come back later'
    visit new_prior_authority_application_send_back_path(application)
    expect(page).to have_checked_field('Further information')
    expect(page).to have_field('Describe what further information you require',
                               with: 'You forgot to say please')
  end
end
