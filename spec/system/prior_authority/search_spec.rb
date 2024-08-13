require 'rails_helper'

RSpec.describe 'Search', :stub_oauth_token do
  let(:caseworker) { create(:caseworker, first_name: 'John', last_name: 'Everyman') }
  let(:endpoint) { 'https://appstore.example.com/v1/submissions/searches' }
  let(:payload) do
    {
      application_type: 'crm4',
      page: 1,
      per_page: 20,
      query: 'QUERY',
      sort_by: 'last_updated',
      sort_direction: 'descending',
    }
  end

  before do
    sign_in caseworker
  end

  context 'when I search for an application that has already been imported' do
    let(:application) { create :prior_authority_application }
    let(:stub) do
      stub_request(:post, endpoint).with(body: payload).to_return(
        status: 201,
        body: { metadata: { total_results: 1 },
                raw_data: [{ application_id: application.id, application: application.data }] }.to_json
      )
    end

    before do
      stub
      application.assignments.create user: caseworker
    end

    it 'lets me search and shows me a result' do
      visit prior_authority_root_path
      click_on 'Search'
      fill_in 'Application details', with: 'QUERY'
      within 'main' do
        click_on 'Search'
      end

      expect(stub).to have_been_requested

      click_on application.data['laa_reference']

      expect(page).to have_current_path prior_authority_application_path(application)
    end
  end

  context 'when the app store has unsynced records' do
    let(:id) { SecureRandom.uuid }
    let(:record) do
      {
        application: build(:prior_authority_data),
        events: [],
        application_id: id,
        application_state: 'submitted',
        application_risk: 'n/1',
        json_schema_version: 1,
        version: 1,
        application_type: 'crm4',
        updated_at: 1.second.ago.to_json
      }.deep_stringify_keys
    end

    before do
      stub_request(:post, endpoint).with(body: payload).to_return(
        status: 201,
        body: { metadata: { total_results: 1 }, raw_data: [record] }.to_json
      )
    end

    it 'imports records it did not have yet' do
      visit prior_authority_search_path(prior_authority_search_form: { query: 'QUERY' })
      expect(PriorAuthorityApplication.find_by(id:)).not_to be_nil
    end
  end

  it 'validates' do
    visit prior_authority_root_path
    click_on 'Search'
    within('main') { click_on 'Search' }
    expect(page).to have_content 'Enter some application details or filter your search criteria'
  end

  context 'if I search for something with no matches' do
    before do
      stub_request(:post, endpoint).with(body: payload).to_return(
        status: 201,
        body: { metadata: { total_results: 0 }, raw_data: [] }.to_json
      )
    end

    it 'tells me if there are no results' do
      visit prior_authority_search_path(prior_authority_search_form: { query: 'QUERY' })
      expect(page).to have_content 'There are no results that match the search criteria'
    end
  end

  context 'when the app store has an error' do
    before do
      stub_request(:post, endpoint).with(body: payload).to_return(
        status: 502
      )
    end

    it 'notifies sentry and shows an error' do
      expect(Sentry).to receive(:capture_exception)
      visit prior_authority_search_path(prior_authority_search_form: { query: 'QUERY' })
      expect(page).to have_content 'Something went wrong trying to perform this search'
    end
  end

  context 'when there are multiple results' do
    let(:applications) { create_list(:prior_authority_application, 20) }
    let(:payloads) do
      [
        { application_type: 'crm4', page: 1, per_page: 20, query: 'QUERY', sort_by: 'last_updated',
sort_direction: 'descending' },
        { application_type: 'crm4', page: 1, per_page: 20, query: 'QUERY', sort_by: 'laa_reference',
sort_direction: 'ascending' },
        { application_type: 'crm4', page: 2, per_page: 20, query: 'QUERY', sort_by: 'laa_reference',
sort_direction: 'ascending' },
      ]
    end

    let(:stubs) do
      payloads.map do |payload|
        stub_request(:post, endpoint).with(body: payload).to_return(
          status: 201, body: { metadata: { total_results: 21 },
                               raw_data: applications.map { { application_id: _1.id, application: _1.data } } }.to_json
        )
      end
    end

    before { stubs }

    it 'lets me sort and paginate' do
      visit prior_authority_search_path(prior_authority_search_form: { query: 'QUERY' })
      within('.govuk-table__head') { click_link 'LAA reference' }
      within('.govuk-pagination__list') { click_on '2' }
      expect(stubs).to all have_been_requested
    end
  end

  context 'when searching with filters' do
    let(:payload) do
      {
        application_type: 'crm4',
        caseworker_id: caseworker.id,
        page: 1,
        per_page: 20,
        sort_by: 'last_updated',
        sort_direction: 'descending',
        status_with_assignment: 'rejected',
        submitted_from: '2023-04-20',
        submitted_to: '2023-04-21',
        updated_from: '2023-04-22',
        updated_to: '2023-04-23'
      }
    end
    let(:stub) do
      stub_request(:post, endpoint).with(body: payload).to_return(
        status: 201,
        body: { metadata: { total_results: 0 }, raw_data: [] }.to_json
      )
    end

    before { stub }

    it 'lets me search and shows me a result' do
      visit prior_authority_root_path
      click_on 'Search'
      within('.govuk-fieldset', text: 'Date submitted from') do
        fill_in 'Day', with: '20'
        fill_in 'Month', with: '4'
        fill_in 'Year', with: '2023'
      end
      within('.govuk-fieldset', text: 'Date submitted to') do
        fill_in 'Day', with: '21'
        fill_in 'Month', with: '4'
        fill_in 'Year', with: '2023'
      end
      within('.govuk-fieldset', text: 'Last updated from') do
        fill_in 'Day', with: '22'
        fill_in 'Month', with: '4'
        fill_in 'Year', with: '2023'
      end
      within('.govuk-fieldset', text: 'Last updated to') do
        fill_in 'Day', with: '23'
        fill_in 'Month', with: '4'
        fill_in 'Year', with: '2023'
      end
      select caseworker.display_name, from: 'Caseworker'
      select 'Rejected', from: 'Status'
      within('main') { click_on 'Search' }

      expect(stub).to have_been_requested
    end
  end
end
