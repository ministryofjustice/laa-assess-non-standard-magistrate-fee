require 'rails_helper'

RSpec.describe 'Assign applications', :stub_oauth_token do
  let(:caseworker) { create(:caseworker) }
  let(:auto_assignment_stub) do
    stub_request(:post, 'https://appstore.example.com/v1/submissions/auto_assignments').to_return(lambda do |request|
      application&.assigned_user_id = JSON.parse(request.body)['current_user_id']
      {
        status: status,
        body: application_data.to_json,
      }
    end)
  end

  let(:status) { 201 }

  let(:application_data) do
    { application_id: application.id,
      assigned_user_id: caseworker.id,
      application_type: 'crm4',
      application_risk: 'medium',
      application_state: 'submitted',
      json_schema_version: 1,
      version: 1,
      application: application.data }
  end

  before do
    stub_app_store_interactions(application)
    auto_assignment_stub
    stub_request(:post, 'https://appstore.example.com/v1/submissions/searches').to_return(
      status: 201,
      body: { metadata: { total_results: 0 }, raw_data: [] }.to_json
    )
    sign_in caseworker
    visit '/'
    click_on 'Accept analytics cookies'
    visit prior_authority_root_path
    application
  end

  context 'when there is an application' do
    let(:application) { build(:prior_authority_application, state: 'submitted') }

    it 'lets me assign the application to myself automatically' do
      click_on 'Assess next application'
      expect(auto_assignment_stub).to have_been_requested
      expect(application.assigned_user_id).to eq caseworker.id
      expect(application.events.find { _1.is_a?(Event::Assignment) }).not_to be_nil
      expect(application.state).to eq 'submitted'
      expect(page).to have_current_path prior_authority_application_path(application)
    end

    context 'when I click to add the application to my list' do
      before do
        visit prior_authority_application_path(application)
        click_on 'Add to my list'
      end

      it 'lets me assign the application to myself manually' do
        fill_in 'Explain your decision', with: 'It looks interesting'
        click_on 'Yes, add to my list'
        expect(application.assigned_user_id).to eq caseworker.id
        expect(application.events.first).to be_an Event::Assignment
        expect(application.state).to eq 'submitted'
        expect(page).to have_current_path prior_authority_application_path(application)
      end

      it 'requires me to enter an explanation' do
        click_on 'Yes, add to my list'
        expect(page).to have_content 'Explain why you are adding this application to your list'
      end
    end

    it 'prevents me from unassigning it' do
      application.assigned_user_id = caseworker.id
      visit new_prior_authority_application_unassignment_path(application)
      application.assigned_user_id = nil
      fill_in 'Explain your decision', with: 'It looks interesting'
      click_on 'Yes, remove from list'
      expect(page).to have_content 'You are not authorised to perform this action'
    end

    context 'when the application is assigned to someone' do
      let(:someone_else) { create(:caseworker) }

      before do
        application.assigned_user_id = someone_else.id
      end

      context "when I click to remove the application from the user's list" do
        before do
          visit prior_authority_application_path(application)
          click_on 'Remove from list'
        end

        it 'lets me assign the application to myself manually' do
          fill_in 'Explain your decision', with: 'They went on holiday'
          click_on 'Yes, remove from list'
          expect(application.assigned_user_id).to be_nil
          expect(application.events.last).to be_an Event::Unassignment
          expect(application.state).to eq 'submitted'
          expect(page).to have_current_path prior_authority_application_path(application)
        end

        it 'requires me to enter an explanation' do
          click_on 'Yes, remove from list'
          expect(page).to have_content 'Explain why you are removing this application from the list'
        end
      end

      it 'prevents me from assigning it to me' do
        visit new_prior_authority_application_manual_assignment_path(application)
        fill_in 'Explain your decision', with: 'It looks interesting'
        click_on 'Yes, add to my list'
        expect(page).to have_content 'This application is already assigned to a caseworker'
      end
    end
  end

  context 'when there is no application' do
    let(:application) { nil }
    let(:application_data) { nil }
    let(:status) { 404 }

    it 'shows me an explanation' do
      click_on 'Assess next application'
      expect(page).to have_content 'There are no applications waiting to be allocated'
    end
  end
end
