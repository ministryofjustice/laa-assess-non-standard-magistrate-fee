require 'rails_helper'

RSpec.describe 'Search', :stub_oauth_token do
  let(:caseworker) { create(:caseworker, first_name: 'John', last_name: 'Everyman') }
  let(:endpoint) { 'https://appstore.example.com/v1/submissions/searches' }

  let(:your_claims_stub) do
    stub_request(:post, endpoint).with(body: your_claims_payload).to_return(
      status: 201,
      body: { metadata: { total_results: 0 },
              raw_data: [] }.to_json
    )
  end

  let(:your_claims_payload) do
    {
      page: 1,
      sort_by: 'last_updated',
      sort_direction: 'descending',
      per_page: 20,
      application_type: 'crm7',
      status_with_assignment: %w[in_progress sent_back provider_updated],
      current_caseworker_id: caseworker.id
    }
  end

  let(:payload) do
    {
      application_type: 'crm7',
      page: 1,
      per_page: 20,
      query: 'QUERY',
      sort_by: 'last_updated',
      sort_direction: 'descending',
    }
  end

  before do
    your_claims_stub
    sign_in caseworker
  end

  it 'displays as expected' do
    visit nsm_root_path
    click_on 'Search'

    expect(page)
      .to have_title('Search for a claim')
      .and have_content('Enter details in at least one field to search for a claim')
  end

  context 'when I search for an application that has already been imported' do
    let(:claim) { create :claim }

    let(:stub) do
      stub_request(:post, endpoint).with(body: payload).to_return(
        status: 201,
        body: { metadata: { total_results: 1 },
                raw_data: [{ application_id: claim.id, application: claim.data }] }.to_json
      )
    end

    before do
      stub
      stub_load_from_app_store(claim)
      claim.assignments.create user: caseworker
    end

    it 'lets me search and shows me a result' do
      visit nsm_root_path
      click_on 'Search'
      fill_in 'Enter any combination', with: 'QUERY'
      within 'main' do
        click_on 'Search'
      end

      expect(stub).to have_been_requested

      click_on claim.data['laa_reference']

      expect(page).to have_current_path nsm_claim_claim_details_path(claim)
    end
  end

  context 'when I search with invalid search criteria' do
    it 'displays an error when no filters applied' do
      visit nsm_root_path
      click_on 'Search'
      within('main') { click_on 'Search' }
      expect(page).to have_content 'Enter some claim details or filter your search criteria'
    end

    it 'displays an error when unparsable date strings used as filters' do
      visit nsm_root_path
      click_on 'Search'
      fill_in 'Submission date from', with: '31/4/2023'
      fill_in 'Submission date to', with: '31/13/2024'
      fill_in 'Last updated from', with: 'adaddddd'
      fill_in 'Last updated to', with: '2024367' # the 367th day of 2024 (a leap year)

      within('main') { click_on 'Search' }

      expect(page)
        .to have_content('Enter a valid submission date from')
        .and have_content('Enter a valid submission date to')
        .and have_content('Enter a valid last updated from')
        .and have_content('Enter a valid last updated to')
    end
  end

  context 'when I search for something with no matches' do
    before do
      stub_request(:post, endpoint).with(body: payload).to_return(
        status: 201,
        body: { metadata: { total_results: 0 }, raw_data: [] }.to_json
      )
    end

    it 'tells me if there are no results' do
      visit nsm_search_path(nsm_search_form: { query: 'QUERY' })
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
      visit nsm_search_path(nsm_search_form: { query: 'QUERY' })
      expect(page).to have_content 'Something went wrong trying to perform this search'
    end
  end

  context 'when there are multiple results' do
    let(:claims) { create_list(:claim, 20) }

    let(:payloads) do
      [
        { application_type: 'crm7', page: 1, per_page: 20, query: 'QUERY',
          sort_by: 'last_updated', sort_direction: 'descending' },
        { application_type: 'crm7', page: 1, per_page: 20, query: 'QUERY',
          sort_by: 'laa_reference', sort_direction: 'ascending' },
        { application_type: 'crm7', page: 2, per_page: 20, query: 'QUERY',
          sort_by: 'laa_reference', sort_direction: 'ascending' },
      ]
    end

    let(:stubs) do
      payloads.map do |payload|
        stub_request(:post, endpoint).with(body: payload).to_return(
          status: 201, body: { metadata: { total_results: 21 },
                               raw_data: claims.map { { application_id: _1.id, application: _1.data } } }.to_json
        )
      end
    end

    before { stubs }

    it 'lets me sort and paginate' do
      visit nsm_search_path(nsm_search_form: { query: 'QUERY' })
      within('.govuk-table__head') { click_link 'LAA reference' }
      within('.govuk-pagination__list') { click_on '2' }
      expect(stubs).to all have_been_requested
    end
  end

  context 'when searching with filters' do
    let(:payload) do
      {
        application_type: 'crm7',
        caseworker_id: caseworker.id,
        page: 1,
        per_page: 20,
        sort_by: 'last_updated',
        sort_direction: 'descending',
        status_with_assignment: 'rejected',
        submitted_from: '20/4/2023',
        submitted_to: '21/4/2023',
        updated_from: '22/4/2023',
        updated_to: '23/4/2023'
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
      visit nsm_root_path
      click_on 'Search'
      fill_in 'Submission date from', with: '20/4/2023'
      fill_in 'Submission date to', with: '21/4/2023'
      fill_in 'Last updated from', with: '22/4/2023'
      fill_in 'Last updated to', with: '23/4/2023'
      select caseworker.display_name, from: 'Caseworker'
      select 'Rejected', from: 'Status'
      within('main') { click_on 'Search' }

      expect(stub).to have_been_requested
    end
  end
end
