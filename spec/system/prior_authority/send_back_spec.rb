require 'rails_helper'

RSpec.describe 'Send an application back', :stub_oauth_token do
  let(:caseworker) { create(:caseworker) }
  let(:application) { build(:prior_authority_application, state: 'submitted') }
  let(:bank_holiday_list) do
    {
      'england-and-wales': {
        events: [
          { date: '2024-01-01' }
        ]
      }
    }
  end

  before do
    stub_request(:post, 'https://appstore.example.com/v1/submissions/searches').to_return(
      status: 201,
      body: { metadata: { total_results: 0 }, raw_data: [] }.to_json
    )

    stub_app_store_interactions(application)

    stub_request(:get, 'https://www.gov.uk/bank-holidays.json').to_return(
      status: 200,
      body: bank_holiday_list.to_json,
      headers: { 'Content-type' => 'application/json' }
    )

    sign_in caseworker
    application.assigned_user_id = caseworker.id
    visit '/'
    click_on 'Accept analytics cookies'
    visit prior_authority_application_path(application)
    click_on 'Send back to provider'
  end

  context 'when I send the application back' do
    before do
      check 'Further information'
      fill_in 'Tell the provider what information they need to add', with: 'You forgot to say please'
    end

    it 'prevents duplicate submission' do
      application.state = 'sent_back'
      click_on 'Submit'
      expect(page).to have_content 'You are not authorised to perform this action'
    end

    context 'once the decision has been processed' do
      before do
        click_on 'Submit'
      end

      it 'shows my application' do
        expect(page).to have_content 'Application sent'
        expect(page).to have_content "Further information request\nYou forgot to say please"
      end

      it 'shows the decision in the history' do
        visit prior_authority_application_events_path(application)
        expect(page).to have_content 'Sent back'
      end

      it 'removes the edit buttons from the application page' do
        click_on 'Return to this application'
        expect(page).to have_no_content 'Make a decision'
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

  it 'requires an explanation for amendment requests' do
    check 'Amendment'
    click_on 'Submit'
    expect(page).to have_content 'Enter a description of what information is incorrect and needs amending'
  end

  it 'lets me save my answers and return later' do
    check 'Further information'
    fill_in 'Tell the provider what information they need to add', with: 'You forgot to say please'
    click_on 'Save and come back later'
    visit new_prior_authority_application_send_back_path(application)
    expect(page).to have_checked_field('Further information')
    expect(page).to have_field('Tell the provider what information they need to add',
                               with: 'You forgot to say please')
  end
end
