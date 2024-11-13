require 'rails_helper'

RSpec.describe 'Assign applications', :stub_oauth_token do
  let(:caseworker) { create(:caseworker) }
  let(:assignment_stub) do
    stub_request(:post, "https://appstore.example.com/v1/submissions/#{application.id}/assignment").to_return(status: 201)
  end

  let(:unassignment_stub) do
    stub_request(:delete, "https://appstore.example.com/v1/submissions/#{application.id}/assignment").to_return(status: 204)
  end

  let(:auto_assignment_stub) do
    stub_request(:post, 'https://appstore.example.com/v1/submissions/auto_assignments').to_return(
      status: status,
      body: application_data.to_json
    )
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
    stub_load_from_app_store(application)
    auto_assignment_stub
    stub_request(:post, "https://appstore.example.com/v1/submissions/#{application&.id}/events").to_return(status: 201)
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
    let(:application) { create(:prior_authority_application, state: 'submitted') }

    it 'lets me assign the application to myself automatically' do
      click_on 'Assess next application'
      expect(application.reload.assignments.first.user).to eq caseworker
      expect(application.events.find_by(event_type: 'Event::Assignment')).not_to be_nil
      expect(application.state).to eq 'submitted'
      expect(page).to have_current_path prior_authority_application_path(application)
      expect(auto_assignment_stub).to have_been_requested
    end

    context 'when application is not saved locally' do
      let(:id) { SecureRandom.uuid }
      let(:application) { build(:prior_authority_application, id: id, state: 'submitted') }

      it 'lets me assign the application to myself automatically' do
        click_on 'Assess next application'
        imported_application = PriorAuthorityApplication.find(id)
        expect(imported_application.assignments.first.user).to eq caseworker
        expect(imported_application.events.find_by(event_type: 'Event::Assignment')).not_to be_nil
        expect(imported_application.state).to eq 'submitted'
        expect(page).to have_current_path prior_authority_application_path(imported_application)
        expect(auto_assignment_stub).to have_been_requested
      end
    end

    context 'when I click to add the application to my list' do
      before do
        assignment_stub
        visit prior_authority_application_path(application)
        click_on 'Add to my list'
      end

      it 'lets me assign the application to myself manually' do
        fill_in 'Explain your decision', with: 'It looks interesting'
        click_on 'Yes, add to my list'
        expect(application.reload.assignments.first.user).to eq caseworker
        expect(application.events.first).to be_an Event::Assignment
        expect(application.state).to eq 'submitted'
        expect(page).to have_current_path prior_authority_application_path(application)
        expect(assignment_stub).to have_been_requested
      end

      it 'requires me to enter an explanation' do
        click_on 'Yes, add to my list'
        expect(page).to have_content 'Explain why you are adding this application to your list'
      end
    end

    it 'prevents me from unassigning it' do
      assignment = create(:assignment, user: caseworker, submission: application)
      visit new_prior_authority_application_unassignment_path(application)
      assignment.destroy
      fill_in 'Explain your decision', with: 'It looks interesting'
      click_on 'Yes, remove from list'
      expect(page).to have_content 'This application is not on a list so cannot be removed from one'
    end

    context 'when the application is assigned to someone' do
      let(:someone_else) { create(:caseworker) }

      before do
        create(:assignment, user: someone_else, submission: application)
      end

      context "when I click to remove the application from the user's list" do
        before do
          unassignment_stub
          visit prior_authority_application_path(application)
          click_on 'Remove from list'
        end

        it 'lets me assign the application to myself manually' do
          fill_in 'Explain your decision', with: 'They went on holiday'
          click_on 'Yes, remove from list'
          expect(application.reload.assignments).to be_empty
          expect(application.events.last).to be_an Event::Unassignment
          expect(application.state).to eq 'submitted'
          expect(page).to have_current_path prior_authority_application_path(application)
          expect(unassignment_stub).to have_been_requested
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
